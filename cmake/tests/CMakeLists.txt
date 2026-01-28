if(NOT PHP_ENABLE_TESTING)
  return()
endif()

include(CheckLinkerFlag)
include(FeatureSummary)

# Add test for all *.phpt files.
if(TARGET PHP::sapi::cli)
  cmake_host_system_information(RESULT processors QUERY NUMBER_OF_LOGICAL_CORES)

  set(parallel "")
  if(processors)
    set(parallel -j${processors})
  endif()

  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
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
      PHP::sapi::cli
        -n
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        run-tests.php
          -n
          -d extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>
          --show-diff
          ${options}
          ${parallel}
          -q
    WORKING_DIRECTORY ${PHP_SOURCE_DIR}
  )
endif()

if(NOT TARGET PHP::sapi::embed)
  return()
endif()

find_package(cmocka 1.1.0)
set_package_properties(
  cmocka
  PROPERTIES
    TYPE RECOMMENDED
    PURPOSE "Necessary to run PHP unit tests."
)

if(NOT cmocka_FOUND)
  return()
endif()

add_executable(
  php_unit_test_network
  unit/main/test_network.c
)

target_link_libraries(
  php_unit_test_network
  PRIVATE
    PHP::sapi::embed
    PHP::config
    cmocka::cmocka
)

check_linker_flag(C LINKER:--wrap=connect PHP_HAS_C_FLAG_WRAP)
if(PHP_HAS_C_FLAG_WRAP)
  target_link_options(
    php_unit_test_network
    PRIVATE
      $<$<LINK_LANGUAGE:C>:LINKER:--wrap=connect>
      $<$<LINK_LANGUAGE:C>:LINKER:--wrap=poll>
      $<$<LINK_LANGUAGE:C>:LINKER:--wrap=getsockopt>
      $<$<LINK_LANGUAGE:C>:LINKER:--wrap=gettimeofday>
  )
endif()

add_test(
  NAME php_unit_test_network
  COMMAND php_unit_test_network
)
