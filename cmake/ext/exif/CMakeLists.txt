#[=============================================================================[
# The exif extension

Configure the `exif` extension.

This extension provides support for working with exchangeable image metadata.

## EXT_EXIF

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_EXIF_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionExif
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_EXIF "Enable the exif extension")

add_feature_info(
  "ext/exif"
  EXT_EXIF
  "exchangeable image file format metadata"
)

cmake_dependent_option(
  EXT_EXIF_SHARED
  "Build the exif extension as a shared library"
  OFF
  "EXT_EXIF;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_EXIF)
  return()
endif()

if(EXT_EXIF_SHARED)
  add_library(php_ext_exif SHARED)
else()
  add_library(php_ext_exif)
endif()

target_sources(
  php_ext_exif
  PRIVATE
    exif.c
    exif.stub.php
)

target_compile_definitions(php_ext_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

# Exif extension optionally depends on the mbstring extension when decoding
# multibyte data in EXIF tags.
if(EXT_MBSTRING)
  add_dependencies(php_ext_exif php_ext_mbstring)
endif()

set(HAVE_EXIF TRUE)

configure_file(cmake/config.h.in config.h)
