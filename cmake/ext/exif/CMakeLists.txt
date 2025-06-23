#[=============================================================================[
# The exif extension

Configure the `exif` extension.

This extension provides support for working with exchangeable image metadata.

## PHP_EXT_EXIF

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_EXIF_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionExif
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_EXIF "Enable the exif extension")

add_feature_info(
  "ext/exif"
  PHP_EXT_EXIF
  "exchangeable image file format metadata"
)

cmake_dependent_option(
  PHP_EXT_EXIF_SHARED
  "Build the exif extension as a shared library"
  OFF
  "PHP_EXT_EXIF;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_EXIF)
  return()
endif()

if(PHP_EXT_EXIF_SHARED)
  add_library(php_ext_exif MODULE)
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
if(PHP_EXT_MBSTRING)
  add_dependencies(php_ext_exif php_ext_mbstring)
endif()

set(HAVE_EXIF TRUE)

configure_file(cmake/config.h.in config.h)
