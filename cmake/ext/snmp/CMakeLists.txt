#[=============================================================================[
# The snmp extension

Configure the `snmp` extension.

This extension provides support for Simple Network Management Protocol (SNMP).

## EXT_SNMP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_SNMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionSnmp
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_SNMP "Enable the snmp extension")

add_feature_info(
  "ext/snmp"
  EXT_SNMP
  "Simple Network Management Protocol (SNMP) support"
)

cmake_dependent_option(
  EXT_SNMP_SHARED
  "Build the snmp extension as a shared library"
  OFF
  "EXT_SNMP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SNMP)
  return()
endif()

if(EXT_SNMP_SHARED)
  add_library(php_snmp SHARED)
else()
  add_library(php_snmp)
endif()

target_sources(
  php_snmp
  PRIVATE
    snmp.c
    snmp.stub.php
)

add_dependencies(php_snmp php_spl)

find_package(NetSnmp 5.3)
set_package_properties(
  NetSnmp
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the snmp extension."
)

target_link_libraries(php_snmp PRIVATE NetSnmp::NetSnmp)

if(TARGET NetSnmp::NetSnmp)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES NetSnmp::NetSnmp)

    check_symbol_exists(
      shutdown_snmp_logging
      "net-snmp/net-snmp-config.h;net-snmp/net-snmp-includes.h"
      HAVE_SHUTDOWN_SNMP_LOGGING
    )

    check_symbol_exists(
      usmHMAC192SHA256AuthProtocol
      "net-snmp/net-snmp-config.h;net-snmp/net-snmp-includes.h"
      HAVE_SNMP_SHA256
    )

    check_symbol_exists(
      usmHMAC384SHA512AuthProtocol
      "net-snmp/net-snmp-config.h;net-snmp/net-snmp-includes.h"
      HAVE_SNMP_SHA512
    )
  cmake_pop_check_state()
endif()

set(HAVE_SNMP TRUE)

configure_file(cmake/config.h.in config.h)
