include(CheckLinkerFlag)
include(FeatureSummary)

# Run extra tests.
if(TARGET PHP::sapi::cli AND NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  add_test(
    NAME PhpRunExtraTests
    COMMAND PHP::sapi::cli ${CMAKE_CURRENT_SOURCE_DIR}/../run-extra-tests.php
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/..
  )
endif()

# PHP unit tests using PHP embed SAPI.
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

# TODO: Fix this.
set_target_properties(php_unit_test_network PROPERTIES PHP_CLI TRUE)

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
  NAME PhpUnitTestNetwork
  COMMAND php_unit_test_network
)
