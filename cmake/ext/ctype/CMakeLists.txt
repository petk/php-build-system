#[=============================================================================[
# The ctype extension

Configure the `ctype` extension.

This extension provides support for character type checking according to the
locale.

## PHP_EXT_CTYPE

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_CTYPE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionCtype
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_CTYPE "Enable the ctype extension" ON)

add_feature_info(
  "ext/ctype"
  PHP_EXT_CTYPE
  "character type checking according to the locale"
)

cmake_dependent_option(
  PHP_EXT_CTYPE_SHARED
  "Build the ctype extension as a shared library"
  OFF
  "PHP_EXT_CTYPE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_CTYPE)
  return()
endif()

if(PHP_EXT_CTYPE_SHARED)
  add_library(php_ext_ctype MODULE)
else()
  add_library(php_ext_ctype)
endif()

target_sources(
  php_ext_ctype
  PRIVATE
    ctype.c
    ctype.stub.php
)

set(HAVE_CTYPE TRUE)

configure_file(cmake/config.h.in config.h)
