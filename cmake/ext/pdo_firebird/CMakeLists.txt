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

include(CheckCXXSymbolExists)
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
  "PHP_EXT_PDO_FIREBIRD;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PDO_FIREBIRD)
  return()
endif()

enable_language(CXX)

if(PHP_EXT_PDO_FIREBIRD_SHARED)
  add_library(php_ext_pdo_firebird MODULE)
else()
  add_library(php_ext_pdo_firebird)
endif()

target_sources(
  php_ext_pdo_firebird
  PRIVATE
    firebird_driver.c
    firebird_statement.c
    pdo_firebird_utils.cpp
    pdo_firebird.c
    pdo_firebird.stub.php
)

target_compile_features(php_ext_pdo_firebird PRIVATE cxx_std_11)

target_compile_options(
  php_ext_pdo_firebird
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/EHsc>
    $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/EHsc>
)

add_dependencies(php_ext_pdo_firebird php_ext_pdo)

find_package(Firebird 3.0)
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
    check_cxx_symbol_exists(
      Firebird::fb_get_master_interface
      firebird/Interface.h
      PHP_EXT_PDO_FIREBIRD_SANITY_CHECK
    )
  cmake_pop_check_state()

  if(NOT PHP_EXT_PDO_FIREBIRD_SANITY_CHECK)
    message(
      FATAL_ERROR
      "Firebird sanity check failed: 'fb_get_master_interface()' not found."
    )
  endif()
endif()
