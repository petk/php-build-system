#[=============================================================================[
# The sysvshm extension

Configure the `sysvshm` extension.

This extension provides the System V shared memory support.

## PHP_EXT_SYSVSHM

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SYSVSHM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionSysVshm
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_SYSVSHM "Enable the sysvshm extension")

add_feature_info(
  "ext/sysvshm"
  PHP_EXT_SYSVSHM
  "System V shared memory support"
)

cmake_dependent_option(
  PHP_EXT_SYSVSHM_SHARED
  "Build the sysvshm extension as a shared library"
  OFF
  "PHP_EXT_SYSVSHM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_SYSVSHM)
  return()
endif()

if(PHP_EXT_SYSVSHM_SHARED)
  add_library(php_ext_sysvshm MODULE)
else()
  add_library(php_ext_sysvshm)
endif()

target_sources(
  php_ext_sysvshm
  PRIVATE
    sysvshm.c
    sysvshm.stub.php
)

set(HAVE_SYSVSHM TRUE)

configure_file(cmake/config.h.in config.h)
