#[=============================================================================[
# The pdo_firebird extension

Configure the `pdo_firebird` extension.

This extension provides PDO interface for using Firebird database.

## EXT_PDO_FIREBIRD

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_PDO_FIREBIRD_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPdoFirebird
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO_FIREBIRD "Enable the pdo_firebird extension")

add_feature_info(
  "ext/pdo_firebird"
  EXT_PDO_FIREBIRD
  "Firebird database support in PDO (PHP Data Objects)"
)

cmake_dependent_option(
  EXT_PDO_FIREBIRD_SHARED
  "Build the pdo_firebird extension as a shared library"
  OFF
  "EXT_PDO_FIREBIRD;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_FIREBIRD)
  return()
endif()

if(EXT_PDO_FIREBIRD_SHARED)
  add_library(php_pdo_firebird SHARED)
else()
  add_library(php_pdo_firebird)
endif()

target_sources(
  php_pdo_firebird
  PRIVATE
    firebird_driver.c
    firebird_statement.c
    pdo_firebird.c
)

add_dependencies(php_pdo_firebird php_pdo)

target_include_directories(
  php_pdo_firebird
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

target_link_libraries(php_pdo_firebird PRIVATE Firebird::Firebird)

# Sanity check.
if(TARGET Firebird::Firebird)
  check_library_exists(
    Firebird::Firebird
    isc_detach_database
    ""
    _php_pdo_firebird_sanity_check
  )
  if(NOT _php_pdo_firebird_sanity_check)
    message(
      FATAL_ERROR
      "Firebird sanity check failed: isc_detach_database() not found."
    )
  endif()
endif()

set(HAVE_PDO_FIREBIRD TRUE)

configure_file(config.cmake.h.in config.h)
