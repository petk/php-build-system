#[=============================================================================[
# The gmp extension

Configure the `gmp` extension.

This extension provides GNU Multiple Precision Arithmetic support.

## EXT_GMP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_GMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionGmp
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_GMP "Enable the gmp extension")

add_feature_info(
  "ext/gmp"
  EXT_GMP
  "GNU Multiple Precision Arithmetic support"
)

cmake_dependent_option(
  EXT_GMP_SHARED
  "Build the gmp extension as a shared library"
  OFF
  "EXT_GMP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_GMP)
  return()
endif()

if(EXT_GMP_SHARED)
  add_library(php_gmp SHARED)
else()
  add_library(php_gmp)
endif()

target_sources(
  php_gmp
  PRIVATE
    gmp.c
    gmp.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_gmp_int.h
)

target_compile_definitions(php_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(GMP 4.2)
set_package_properties(
  GMP
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gmp extension."
)

target_link_libraries(php_gmp PUBLIC GMP::GMP)

add_dependencies(php_gmp php_random)

set(HAVE_GMP TRUE)

configure_file(cmake/config.h.in config.h)
