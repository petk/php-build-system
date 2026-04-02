#[=============================================================================[
# The sysvshm extension

This extension provides the System V shared memory support.

## Configuration options

### PHP_EXT_SYSVSHM

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_SYSVSHM
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_SYSVSHM "Enable the sysvshm extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/sysvshm"
  PHP_EXT_SYSVSHM
  "System V shared memory support"
)

if(NOT PHP_EXT_SYSVSHM)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(sysvshm)

if(PHP_EXT_SYSVSHM STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_sysvshm MODULE)
else()
  add_library(php_ext_sysvshm OBJECT)
endif()

target_sources(
  php_ext_sysvshm
  PRIVATE
    sysvshm.c
    sysvshm.stub.php
)

target_include_directories(php_ext_sysvshm PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

set(HAVE_SYSVSHM TRUE)

configure_file(cmake/config.h.in config.h)
