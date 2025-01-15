#[=============================================================================[
# The sysvsem extension

Configure the `sysvsem` extension.

This extension provides the System V semaphore support.

> [!NOTE]
> This extension is available only on \*nix systems.

## PHP_EXT_SYSVSEM

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SYSVSEM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionSysVsem
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_SYSVSEM "Enable the sysvsem extension")

add_feature_info(
  "ext/sysvsem"
  PHP_EXT_SYSVSEM
  "System V semaphore support"
)

cmake_dependent_option(
  PHP_EXT_SYSVSEM_SHARED
  "Build the sysvsem extension as a shared library"
  OFF
  "PHP_EXT_SYSVSEM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_SYSVSEM)
  return()
endif()

if(PHP_EXT_SYSVSEM_SHARED)
  add_library(php_ext_sysvsem SHARED)
else()
  add_library(php_ext_sysvsem)
endif()

target_sources(
  php_ext_sysvsem
  PRIVATE
    sysvsem.c
    sysvsem.stub.php
)

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/types.h;sys/ipc.h;sys/sem.h")
  check_type_size("union semun" UNION_SEMUN)
cmake_pop_check_state()

set(HAVE_SYSVSEM TRUE)

configure_file(cmake/config.h.in config.h)
