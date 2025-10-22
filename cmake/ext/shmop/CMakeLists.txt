#[=============================================================================[
# The shmop extension

Configure the `shmop` extension.

This extension provides support for shared memory segments operations.

## PHP_EXT_SHMOP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SHMOP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PhpExtensionShmopo
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_SHMOP "Enable the shmop extension")

add_feature_info(
  "ext/shmop"
  PHP_EXT_SHMOP
  "shared memory segments operations support"
)

cmake_dependent_option(
  PHP_EXT_SHMOP_SHARED
  "Build the shmop extension as a shared library"
  OFF
  PHP_EXT_SHMOP
  OFF
)

if(NOT PHP_EXT_SHMOP)
  return()
endif()

if(PHP_EXT_SHMOP_SHARED)
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

set(HAVE_SHMOP TRUE)

configure_file(cmake/config.h.in config.h)
