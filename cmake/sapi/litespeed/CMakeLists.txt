#[=============================================================================[
# The litespeed SAPI

Configure the `litespeed` PHP SAPI.

> [!NOTE]
> The PHP Litespeed SAPI is not available when the target system is Windows.

## PHP_SAPI_LITESPEED

* Default: `OFF`
* Values: `ON|OFF`

Enable the LiteSpeed SAPI module.
#]=============================================================================]

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(FeatureSummary)

option(PHP_SAPI_LITESPEED "Enable the LiteSpeed SAPI module")

add_feature_info(
  "sapi/litespeed"
  PHP_SAPI_LITESPEED
  "LiteSpeed web server module"
)

if(NOT PHP_SAPI_LITESPEED)
  return()
endif()

add_executable(php_sapi_litespeed)
add_executable(PHP::sapi::litespeed ALIAS php_sapi_litespeed)

target_sources(
  php_sapi_litespeed
  PRIVATE
    lsapi_main.c
    lsapi_main.stub.php
    lsapilib.c
)

target_link_libraries(
  php_sapi_litespeed
  PRIVATE
    $<BUILD_INTERFACE:PHP::sapi>
)

set_target_properties(
  php_sapi_litespeed
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}lsphp${PHP_PROGRAM_SUFFIX}
)

install(
  TARGETS php_sapi_litespeed
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT php-sapi-litespeed
)
