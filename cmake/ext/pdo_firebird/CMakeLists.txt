#[=============================================================================[
# The pdo_firebird extension

This extension provides PDO interface for using Firebird database.

## Configuration options

### PHP_EXT_PDO_FIREBIRD

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PDO_FIREBIRD
  LANGUAGES C
)

include(CheckCXXSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)

option(
  PHP_EXT_PDO_FIREBIRD
  "Enable the pdo_firebird extension"
  ${PROJECT_IS_TOP_LEVEL}
)

add_feature_info(
  "ext/pdo_firebird"
  PHP_EXT_PDO_FIREBIRD
  "Firebird database PDO driver"
)

if(NOT PHP_EXT_PDO_FIREBIRD)
  return()
endif()

enable_language(CXX)

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo_firebird)

if(PHP_EXT_PDO_FIREBIRD STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_pdo_firebird MODULE)
else()
  add_library(php_ext_pdo_firebird OBJECT)
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

set_property(
  TARGET php_ext_pdo_firebird
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pdo
)

target_include_directories(
  php_ext_pdo_firebird
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}
)

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
