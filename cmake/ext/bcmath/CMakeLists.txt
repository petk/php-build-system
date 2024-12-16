#[=============================================================================[
# The bcmath extension

Configure the `bcmath` extension.

This extension provides Basic Calculator (BC) style precision math support.

## EXT_BCMATH

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_BCMATH_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionBcMath
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_BCMATH "Enable the bcmath extension")

add_feature_info(
  "ext/bcmath"
  EXT_BCMATH
  "Basic Calculator (BC) style precision math support"
)

cmake_dependent_option(
  EXT_BCMATH_SHARED
  "Build the bcmath extension as a shared library"
  OFF
  "EXT_BCMATH;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_BCMATH)
  return()
endif()

if(EXT_BCMATH_SHARED)
  add_library(php_ext_bcmath SHARED)
else()
  add_library(php_ext_bcmath)
endif()

target_sources(
  php_ext_bcmath
  PRIVATE
    bcmath.c
    bcmath.stub.php
    libbcmath/src/add.c
    libbcmath/src/compare.c
    libbcmath/src/debug.c
    libbcmath/src/div.c
    libbcmath/src/divmod.c
    libbcmath/src/doaddsub.c
    libbcmath/src/init.c
    libbcmath/src/int2num.c
    libbcmath/src/nearzero.c
    libbcmath/src/neg.c
    libbcmath/src/num2long.c
    libbcmath/src/num2str.c
    libbcmath/src/output.c
    libbcmath/src/raise.c
    libbcmath/src/raisemod.c
    libbcmath/src/recmul.c
    libbcmath/src/rmzero.c
    libbcmath/src/sqrt.c
    libbcmath/src/str2num.c
    libbcmath/src/sub.c
    libbcmath/src/zero.c
)

target_compile_definitions(php_ext_bcmath PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

set(HAVE_BCMATH TRUE)

configure_file(cmake/config.h.in config.h)
