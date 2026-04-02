#[=============================================================================[
# The shmop extension

This extension provides support for shared memory segments operations.

## Configuration options

### PHP_EXT_SHMOP

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_SHMOP
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_SHMOP "Enable the shmop extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/shmop"
  PHP_EXT_SHMOP
  "shared memory segments operations support"
)

if(NOT PHP_EXT_SHMOP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(shmop)

if(PHP_EXT_SHMOP STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_shmop MODULE)
else()
  add_library(php_ext_shmop OBJECT)
endif()

target_sources(
  php_ext_shmop
  PRIVATE
    shmop.c
    shmop.stub.php
)

target_include_directories(php_ext_shmop PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

set(HAVE_SHMOP TRUE)

configure_file(cmake/config.h.in config.h)
