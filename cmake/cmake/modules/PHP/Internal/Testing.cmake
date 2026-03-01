#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It provides PHP testing configuration.

Load this module in a CMake project with:

  include(PHP/Internal/Testing)

Commands

This module provides the following commands:

php_testing_add()

  Adds CMake test via add_test() for running run-tests.php script:

    php_testing_add([<extension>])

  The arguments are:

  * <extension> - Optional name of the PHP extension being configured. If this
    argument is not given it defaults to all enabled extensions in the current
    configuration (when building php-src).
#]=============================================================================]

include_guard(GLOBAL)

function(php_testing_add)
  add_test(
    NAME PhpRunTests
    COMMAND
      ${CMAKE_COMMAND}
      -P
      ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/$<CONFIG>/run-tests.cmake
  )

  set_tests_properties(PhpRunTests PROPERTIES RUN_SERIAL TRUE)

  cmake_language(
    EVAL CODE
    "cmake_language(DEFER CALL _php_testing_post_configure \"${ARGV0}\")"
  )
endfunction()

function(_php_testing_post_configure)
  if(TARGET PHP::sapi::cli)
    set(php_executable "PHP::sapi::cli")
    set(run_tests "run-tests.php")
    get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
  elseif(TARGET PHP::Interpreter)
    set(php_executable "PHP::Interpreter")

    if(NOT EXISTS ${PHP_INSTALL_LIBDIR}/build/run-tests.php)
      message(
        WARNING
        "'${PHP_INSTALL_LIBDIR}/build/run-tests.php' is missing. "
        "Default tests for the ${extension} extension are not configured."
      )

      set_tests_properties(PhpRunTests PROPERTIES DISABLED TRUE)

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

    set(extensions "${ARGV0}")
  else()
    set_tests_properties(PhpRunTests PROPERTIES DISABLED TRUE)
    return()
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

  string(
    CONFIGURE
    [[
      cmake_minimum_required(VERSION 4.2...4.3)

      execute_process(
        COMMAND
          "$<TARGET_FILE:@php_executable@>"
            -n
            -d open_basedir=
            -d output_buffering=0
            -d memory_limit=-1
            "@run_tests@"
              -n
              -d extension_dir="@CMAKE_CURRENT_BINARY_DIR@/modules/$<CONFIG>"
              --show-diff
              @options@
              @parallel@
              -q
        WORKING_DIRECTORY "@CMAKE_CURRENT_SOURCE_DIR@"
        COMMAND_ERROR_IS_FATAL ANY
      )
    ]]
    content
    @ONLY
  )
  file(
    GENERATE
    OUTPUT CMakeFiles/PHP/$<CONFIG>/run-tests.cmake
    CONTENT "${content}"
  )
endfunction()
