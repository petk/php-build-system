#[=============================================================================[
# The bcmath extension

This extension provides Basic Calculator (BC) style precision math support.

## Configuration options

### PHP_EXT_BCMATH

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_BCMATH_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_BCMATH
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_BCMATH "Enable the bcmath extension")

add_feature_info(
  "ext/bcmath"
  PHP_EXT_BCMATH
  "Basic Calculator (BC) style precision math support"
)

cmake_dependent_option(
  PHP_EXT_BCMATH_SHARED
  "Build the bcmath extension as a shared library"
  OFF
  PHP_EXT_BCMATH
  OFF
)

if(NOT PHP_EXT_BCMATH)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(bcmath)

if(PHP_EXT_BCMATH_SHARED)
  add_library(php_ext_bcmath MODULE)
else()
  add_library(php_ext_bcmath OBJECT)
endif()

target_sources(
  php_ext_bcmath
  PRIVATE
    bcmath.c
    bcmath.stub.php
    libbcmath/src/add.c
    libbcmath/src/compare.c
    libbcmath/src/convert.c
    libbcmath/src/div.c
    libbcmath/src/divmod.c
    libbcmath/src/doaddsub.c
    libbcmath/src/floor_or_ceil.c
    libbcmath/src/init.c
    libbcmath/src/int2num.c
    libbcmath/src/long2num.c
    libbcmath/src/nearzero.c
    libbcmath/src/neg.c
    libbcmath/src/num2long.c
    libbcmath/src/num2str.c
    libbcmath/src/raise.c
    libbcmath/src/raisemod.c
    libbcmath/src/recmul.c
    libbcmath/src/rmzero.c
    libbcmath/src/round.c
    libbcmath/src/sqrt.c
    libbcmath/src/str2num.c
    libbcmath/src/sub.c
    libbcmath/src/zero.c
)

target_compile_definitions(php_ext_bcmath PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

set(HAVE_BCMATH TRUE)

configure_file(cmake/config.h.in config.h)
