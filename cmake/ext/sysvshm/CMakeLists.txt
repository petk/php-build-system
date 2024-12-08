#[=============================================================================[
# The sysvshm extension

Configure the `sysvshm` extension.

This extension provides the System V shared memory support.

## EXT_SYSVSHM

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_SYSVSHM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionSysVshm
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SYSVSHM "Enable the sysvshm extension")

add_feature_info(
  "ext/sysvshm"
  EXT_SYSVSHM
  "System V shared memory support"
)

cmake_dependent_option(
  EXT_SYSVSHM_SHARED
  "Build the sysvshm extension as a shared library"
  OFF
  "EXT_SYSVSHM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVSHM)
  return()
endif()

if(EXT_SYSVSHM_SHARED)
  add_library(php_sysvshm SHARED)
else()
  add_library(php_sysvshm)
endif()

target_sources(
  php_sysvshm
  PRIVATE
    sysvshm.c
    sysvshm.stub.php
)

set(HAVE_SYSVSHM TRUE)

configure_file(cmake/config.h.in config.h)
