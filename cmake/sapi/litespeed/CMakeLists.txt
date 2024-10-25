# SAPI is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(FeatureSummary)

option(SAPI_LITESPEED "Enable the LiteSpeed SAPI module" OFF)

add_feature_info(
  "sapi/litespeed"
  SAPI_LITESPEED
  "LiteSpeed SAPI module"
)

message(CHECK_START "Checking litespeed SAPI")
if(NOT SAPI_LITESPEED)
  message(CHECK_FAIL "disabled")
  return()
endif()
message(CHECK_PASS "enabled")

add_executable(php_litespeed
  lsapi_main.c
  lsapi_main.stub.php
  lsapilib.c
)

target_link_libraries(
  php_litespeed
  PRIVATE
    PHP::main
    Zend::Zend
)

set_target_properties(
  php_litespeed
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}lsphp${PHP_PROGRAM_SUFFIX}
    # TODO: Check if there's a better solution here.
    ENABLE_EXPORTS TRUE
)

install(
  TARGETS php_litespeed
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
