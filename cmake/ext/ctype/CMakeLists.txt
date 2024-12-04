#[=============================================================================[
# The ctype extension

Configure the `ctype` extension.

This extension provides support for character type checking according to the
locale.

## EXT_CTYPE

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_CTYPE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionCtype
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_CTYPE "Enable the ctype extension" ON)

add_feature_info(
  "ext/ctype"
  EXT_CTYPE
  "character type checking according to the locale"
)

cmake_dependent_option(
  EXT_CTYPE_SHARED
  "Build the ctype extension as a shared library"
  OFF
  "EXT_CTYPE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_CTYPE)
  return()
endif()

if(EXT_CTYPE_SHARED)
  add_library(php_ctype SHARED)
else()
  add_library(php_ctype)
endif()

target_sources(
  php_ctype
  PRIVATE
    ctype.c
    ctype.stub.php
)

set(HAVE_CTYPE TRUE)

configure_file(cmake/config.h.in config.h)
