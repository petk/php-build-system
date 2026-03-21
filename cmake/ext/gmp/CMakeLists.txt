#[=============================================================================[
# The gmp extension

This extension provides GNU Multiple Precision Arithmetic support.

## Configuration options

### PHP_EXT_GMP

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_GMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_GMP
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_GMP "Enable the gmp extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/gmp"
  PHP_EXT_GMP
  "GNU Multiple Precision Arithmetic support"
)

cmake_dependent_option(
  PHP_EXT_GMP_SHARED
  "Build the gmp extension as a shared library"
  ${PROJECT_IS_TOP_LEVEL}
  PHP_EXT_GMP
  OFF
)

if(NOT PHP_EXT_GMP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(gmp)

if(PHP_EXT_GMP_SHARED OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_gmp MODULE)
else()
  add_library(php_ext_gmp OBJECT)
endif()

target_sources(
  php_ext_gmp
  PRIVATE
    gmp.c
    gmp.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_gmp_int.h
)

target_include_directories(php_ext_gmp PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(php_ext_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(GMP 4.2)
set_package_properties(
  GMP
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gmp extension."
)

target_link_libraries(php_ext_gmp PUBLIC GMP::GMP)

set_property(
  TARGET php_ext_gmp
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS random
)

set(HAVE_GMP TRUE)

configure_file(cmake/config.h.in config.h)
