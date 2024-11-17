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

option(EXT_PDO_FIREBIRD "Enable the pdo_firebird extension" OFF)

add_feature_info(
  "ext/pdo_firebird"
  EXT_PDO_FIREBIRD
  "Firebird database support in PDO (PHP Data Objects) interface"
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

enable_language(CXX)

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
    pdo_firebird_utils.cpp
    pdo_firebird.c
    pdo_firebird.stub.php
)

set_target_properties(
  php_pdo_firebird
  PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED TRUE
)

target_compile_options(
  php_pdo_firebird
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/EHsc>
    $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/EHsc>
)

add_dependencies(php_pdo_firebird php_pdo)

find_package(Firebird 3.0)
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
    fb_get_master_interface
    ""
    _php_pdo_firebird_sanity_check
  )
  if(NOT _php_pdo_firebird_sanity_check)
    message(
      FATAL_ERROR
      "Firebird sanity check failed: fb_get_master_interface() not found."
    )
  endif()
endif()
