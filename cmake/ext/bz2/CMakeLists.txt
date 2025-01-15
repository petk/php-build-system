#[=============================================================================[
# The bz2 extension

Configure the `bz2` extension.

This extension provides support for reading and writing BZip2 (.bz2) compressed
files.

## PHP_EXT_BZ2

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_BZ2_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionBz2
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_BZ2 "Enable the bz2 extension")

add_feature_info(
  "ext/bz2"
  PHP_EXT_BZ2
  "BZip2 (.bz2) compressed archives support"
)

cmake_dependent_option(
  PHP_EXT_BZ2_SHARED
  "Build the bz2 extension as a shared library"
  OFF
  "PHP_EXT_BZ2;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_BZ2)
  return()
endif()

if(PHP_EXT_BZ2_SHARED)
  add_library(php_ext_bz2 SHARED)
else()
  add_library(php_ext_bz2)
endif()

target_sources(
  php_ext_bz2
  PRIVATE
    bz2_filter.c
    bz2.c
    bz2.stub.php
)

target_compile_definitions(
  php_ext_bz2
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:PHP_BZ2_EXPORTS>
)

find_package(BZip2 ${PHP_BZIP2_MIN_VERSION})
set_package_properties(
  BZip2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the bz2 extension."
)

# Link with PUBLIC scope if include directories are on non-standard places.
target_link_libraries(php_ext_bz2 PUBLIC BZip2::BZip2)

# Sanity check.
if(TARGET BZip2::BZip2)
  check_library_exists(BZip2::BZip2 BZ2_bzerror "" _HAVE_BZ2_BZERROR)

  if(NOT _HAVE_BZ2_BZERROR)
    message(
      FATAL_ERROR
      "BZip2 package is not working as expected. The bz2 extension requires "
      "BZip2 library (libbzip2) version ${PHP_BZIP2_MIN_VERSION} or later."
    )
  endif()
endif()

set(HAVE_BZ2 TRUE)

configure_file(cmake/config.h.in config.h)
