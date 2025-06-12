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

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionBz2
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
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

find_package(BZip2 1.0.0)
set_package_properties(
  BZip2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the bz2 extension."
)

# Minimum version sanity check.
if(TARGET BZip2::BZip2)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES BZip2::BZip2)

    # bzip versions 1.0.1 and earlier required <stdio.h> to be included before
    # bzlib.h, to have FILE definition. In 1.0.4, minor version (4) has been
    # updated in the bzlib.h header. BZ2_bzerror() is available as of 1.0.0.
    block()
      set(headers "bzlib.h")
      if(BZip2_VERSION VERSION_LESS 1.0.4)
        list(PREPEND headers "stdio.h")
      endif()
      check_symbol_exists(BZ2_bzerror "${headers}" PHP_EXT_BZ2_SANITY_CHECK)
    endblock()

    if(NOT PHP_EXT_BZ2_SANITY_CHECK)
      message(
        FATAL_ERROR
        "ext/bz2 sanity check failed: BZ2_bzerror() could not be found. "
        "BZip2 library (libbzip2) version 1.0.0 or later is required."
      )
    endif()
  cmake_pop_check_state()
endif()

# Link with PUBLIC scope if include directories are on non-standard places.
target_link_libraries(php_ext_bz2 PUBLIC BZip2::BZip2)

set(HAVE_BZ2 TRUE)

configure_file(cmake/config.h.in config.h)
