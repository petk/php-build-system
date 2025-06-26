#[=============================================================================[
# The pdo_firebird extension

Configure the `pdo_firebird` extension.

This extension provides PDO interface for using Firebird database.

## PHP_EXT_PDO_FIREBIRD

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PDO_FIREBIRD_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionPdoFirebird
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_PDO_FIREBIRD "Enable the pdo_firebird extension")

add_feature_info(
  "ext/pdo_firebird"
  PHP_EXT_PDO_FIREBIRD
  "Firebird database PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_FIREBIRD_SHARED
  "Build the pdo_firebird extension as a shared library"
  OFF
  PHP_EXT_PDO_FIREBIRD
  OFF
)

if(NOT PHP_EXT_PDO_FIREBIRD)
  return()
endif()

if(PHP_EXT_PDO_FIREBIRD_SHARED)
  add_library(php_ext_pdo_firebird MODULE)
else()
  add_library(php_ext_pdo_firebird OBJECT)
endif()

target_sources(
  php_ext_pdo_firebird
  PRIVATE
    firebird_driver.c
    firebird_statement.c
    pdo_firebird.c
)

add_dependencies(php_ext_pdo_firebird php_ext_pdo)

target_include_directories(
  php_ext_pdo_firebird
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

find_package(Firebird)
set_package_properties(
  Firebird
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_firebird extension."
)

target_link_libraries(php_ext_pdo_firebird PRIVATE Firebird::Firebird)

# Sanity check.
if(TARGET Firebird::Firebird)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Firebird::Firebird)
    check_symbol_exists(
      isc_detach_database
      ibase.h
      PHP_EXT_PDO_FIREBIRD_SANITY_CHECK
    )
  cmake_pop_check_state()

  if(NOT PHP_EXT_PDO_FIREBIRD_SANITY_CHECK)
    message(
      FATAL_ERROR
      "Firebird sanity check failed: 'isc_detach_database()' not found."
    )
  endif()
endif()

set(HAVE_PDO_FIREBIRD TRUE)

configure_file(cmake/config.h.in config.h)
