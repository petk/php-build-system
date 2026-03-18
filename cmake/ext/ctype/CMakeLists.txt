#[=============================================================================[
# The ctype extension

This extension provides support for character type checking according to the
locale.

## Configuration options

### PHP_EXT_CTYPE

* Default: `ON`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_CTYPE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_CTYPE
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
  ${PROJECT_IS_TOP_LEVEL}
  PHP_EXT_CTYPE
  OFF
)

if(NOT PHP_EXT_CTYPE)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(ctype)

if(PHP_EXT_CTYPE_SHARED OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_ctype MODULE)
else()
  add_library(php_ext_ctype OBJECT)
endif()

target_sources(
  php_ext_ctype
  PRIVATE
    ctype.c
    ctype.stub.php
)

target_include_directories(php_ext_ctype PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

set(HAVE_CTYPE TRUE)

configure_file(cmake/config.h.in config.h)
