#[=============================================================================[
# The exif extension

This extension provides support for working with exchangeable image metadata.

## Configuration options

### PHP_EXT_EXIF

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_EXIF
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_EXIF "Enable the exif extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/exif"
  PHP_EXT_EXIF
  "exchangeable image file format metadata"
)

if(NOT PHP_EXT_EXIF)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(exif)

if(PHP_EXT_EXIF STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_exif MODULE)
else()
  add_library(php_ext_exif OBJECT)
endif()

target_sources(
  php_ext_exif
  PRIVATE
    exif.c
    exif.stub.php
)

target_include_directories(php_ext_exif PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(php_ext_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

# Exif extension optionally depends on the mbstring extension when decoding
# multibyte data in EXIF tags.
set_property(
  TARGET php_ext_exif
  APPEND
  PROPERTY PHP_OPTIONAL_EXTENSIONS mbstring
)

set(HAVE_EXIF TRUE)

configure_file(cmake/config.h.in config.h)
