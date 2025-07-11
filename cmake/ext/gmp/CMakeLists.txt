#[=============================================================================[
# The gmp extension

Configure the `gmp` extension.

This extension provides GNU Multiple Precision Arithmetic support.

## PHP_EXT_GMP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_GMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionGmp
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_GMP "Enable the gmp extension")

add_feature_info(
  "ext/gmp"
  PHP_EXT_GMP
  "GNU Multiple Precision Arithmetic support"
)

cmake_dependent_option(
  PHP_EXT_GMP_SHARED
  "Build the gmp extension as a shared library"
  OFF
  PHP_EXT_GMP
  OFF
)

if(NOT PHP_EXT_GMP)
  return()
endif()

if(PHP_EXT_GMP_SHARED)
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

target_compile_definitions(php_ext_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(GMP 4.2)
set_package_properties(
  GMP
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gmp extension."
)

target_link_libraries(php_ext_gmp PUBLIC GMP::GMP)

add_dependencies(php_ext_gmp php_ext_random)

set(HAVE_GMP TRUE)

configure_file(cmake/config.h.in config.h)
