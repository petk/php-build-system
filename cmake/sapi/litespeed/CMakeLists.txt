#[=============================================================================[
# The litespeed SAPI

Configure the `litespeed` PHP SAPI.

> [!NOTE]
> The PHP Litespeed SAPI is not available when the target system is Windows.

## SAPI_LITESPEED

* Default: `OFF`
* Values: `ON|OFF`

Enable the LiteSpeed SAPI module.
#]=============================================================================]

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(FeatureSummary)

option(SAPI_LITESPEED "Enable the LiteSpeed SAPI module")

add_feature_info(
  "sapi/litespeed"
  SAPI_LITESPEED
  "LiteSpeed SAPI module"
)

if(NOT SAPI_LITESPEED)
  return()
endif()

add_executable(php_litespeed)
add_executable(PHP::litespeed ALIAS php_litespeed)

target_sourceS(
  php_litespeed
  PRIVATE
    lsapi_main.c
    lsapi_main.stub.php
    lsapilib.c
)

target_link_libraries(
  php_litespeed
  PRIVATE
    PHP::PHP
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
