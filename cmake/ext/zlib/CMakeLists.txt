#[=============================================================================[
# The zlib extension

Configure the `zlib` extension.

This extension provides support for reading and writing gzip (.gz) compressed
files.

## PHP_EXT_ZLIB

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_ZLIB_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionZlib
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_ZLIB "Enable the zlib extension")

add_feature_info(
  "ext/zlib"
  PHP_EXT_ZLIB
  "gzip (.gz) compressed archives support"
)

cmake_dependent_option(
  PHP_EXT_ZLIB_SHARED
  "Build the zlib extension as a shared library"
  OFF
  PHP_EXT_ZLIB
  OFF
)

if(NOT PHP_EXT_ZLIB)
  return()
endif()

if(PHP_EXT_ZLIB_SHARED)
  add_library(php_ext_zlib MODULE)
else()
  add_library(php_ext_zlib OBJECT)
endif()

target_sources(
  php_ext_zlib
  PRIVATE
    zlib_filter.c
    zlib_fopen_wrapper.c
    zlib.c
    zlib.stub.php
)

get_target_property(type php_ext_zlib TYPE)
if(
  CMAKE_SYSTEM_NAME STREQUAL "Windows"
  AND TARGET php_sapi
  AND NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$"
)
  target_sources(php_sapi INTERFACE php_zlib.def)
endif()

target_compile_definitions(php_ext_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})
set_package_properties(
  ZLIB
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the zlib extension."
)

# Link publicly for internal_functions files.
target_link_libraries(php_ext_zlib PUBLIC ZLIB::ZLIB)

set(HAVE_ZLIB TRUE)

configure_file(cmake/config.h.in config.h)
