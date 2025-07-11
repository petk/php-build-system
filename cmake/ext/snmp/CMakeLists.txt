#[=============================================================================[
# The snmp extension

Configure the `snmp` extension.

This extension provides support for Simple Network Management Protocol (SNMP).

## PHP_EXT_SNMP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SNMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionSnmp
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_SNMP "Enable the snmp extension")

add_feature_info(
  "ext/snmp"
  PHP_EXT_SNMP
  "Simple Network Management Protocol (SNMP) support"
)

cmake_dependent_option(
  PHP_EXT_SNMP_SHARED
  "Build the snmp extension as a shared library"
  OFF
  PHP_EXT_SNMP
  OFF
)

if(NOT PHP_EXT_SNMP)
  return()
endif()

if(PHP_EXT_SNMP_SHARED)
  add_library(php_ext_snmp MODULE)
else()
  add_library(php_ext_snmp OBJECT)
endif()

target_sources(
  php_ext_snmp
  PRIVATE
    snmp.c
    snmp.stub.php
)

add_dependencies(php_ext_snmp php_ext_spl)

find_package(NetSnmp 5.3)
set_package_properties(
  NetSnmp
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the snmp extension."
)

target_link_libraries(php_ext_snmp PRIVATE NetSnmp::NetSnmp)

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
