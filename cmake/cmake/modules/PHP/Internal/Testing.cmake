#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It provides PHP testing configuration.

Load this module in a PHP CMake project or inside a module with:

  include(PHP/Internal/Testing)

Commands

This module provides the following commands:

_php_testing_add_test()

  Adds CMake test via add_test() for running run-tests.php script:

    _php_testing_add_test(<extensions>)

  The arguments are:

  * <extensions> - A semicolon-separated list of one or more PHP extensions.
#]=============================================================================]

include_guard(GLOBAL)

function(_php_testing_add_test extensions)
  if(TARGET PHP::sapi::cli)
    set(php_executable "PHP::sapi::cli")
    set(run_tests "run-tests.php")
    set(extension_dir "${PHP_BINARY_DIR}/modules")
    set(working_dir "${PHP_SOURCE_DIR}")
  elseif(TARGET PHP::Interpreter)
    set(php_executable "PHP::Interpreter")

    if(NOT EXISTS ${PHP_INSTALL_LIBDIR}/build/run-tests.php)
      message(
        WARNING
        "'${PHP_INSTALL_LIBDIR}/build/run-tests.php' is missing. "
        "Default tests for the ${extension} extension are not configured."
      )
      return()
    endif()

    # Copy run-tests.php to the current binary directory as it writes some
    # temporary files inside its containing directory.
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP)
    file(
      COPY
      ${PHP_INSTALL_LIBDIR}/build/run-tests.php
      DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP
    )

    set(run_tests "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/run-tests.php")
    set(extension_dir "${CMAKE_CURRENT_BINARY_DIR}/modules")
    set(working_dir "${CMAKE_CURRENT_SOURCE_DIR}")
  else()
    return()
  endif()

  get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(NOT is_multi_config)
    string(APPEND extension_dir "/$<CONFIG>")
  endif()

  cmake_host_system_information(RESULT processors QUERY NUMBER_OF_LOGICAL_CORES)

  set(parallel "")
  if(processors)
    set(parallel -j${processors})
  endif()

  set(options "")
  foreach(extension IN LISTS extensions)
    get_target_property(type PHP::ext::${extension} TYPE)
    if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      get_target_property(
        is_zend_extension
        PHP::ext::${extension}
        PHP_ZEND_EXTENSION
      )
      if(is_zend_extension)
        list(APPEND options -d zend_extension=${extension})
      elseif(NOT extension STREQUAL "dl_test")
        list(APPEND options -d extension=${extension})
      endif()
    endif()
  endforeach()

  add_test(
    NAME PHP
    COMMAND
      ${php_executable}
        -n
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        ${run_tests}
          -n
          -d extension_dir=${extension_dir}
          --show-diff
          ${options}
          ${parallel}
          -q
    WORKING_DIRECTORY ${working_dir}
  )

  set_tests_properties(PHP PROPERTIES RUN_SERIAL TRUE)
endfunction()
