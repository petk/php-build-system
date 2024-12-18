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
  "PHP_EXT_ZLIB;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_ZLIB)
  return()
endif()

if(PHP_EXT_ZLIB_SHARED)
  add_library(php_ext_zlib SHARED)
else()
  add_library(php_ext_zlib)
endif()

target_sources(
  php_ext_zlib
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:php_zlib.def>
    zlib_filter.c
    zlib_fopen_wrapper.c
    zlib.c
    zlib.stub.php
)

target_compile_definitions(php_ext_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})
set_package_properties(
  ZLIB
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the zlib extension."
)

target_link_libraries(php_ext_zlib PRIVATE ZLIB::ZLIB)

set(HAVE_ZLIB TRUE)

configure_file(cmake/config.h.in config.h)
