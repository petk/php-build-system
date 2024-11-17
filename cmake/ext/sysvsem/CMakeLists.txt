#[=============================================================================[
# The sysvsem extension

Configure the `sysvsem` extension.

This extension provides the System V semaphore support.

> [!NOTE]
> This extension is available only on \*nix systems.

## EXT_SYSVSEM

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_SYSVSEM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

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

option(EXT_SYSVSEM "Enable the sysvsem extension" OFF)

add_feature_info(
  "ext/sysvsem"
  EXT_SYSVSEM
  "System V semaphore support"
)

cmake_dependent_option(
  EXT_SYSVSEM_SHARED
  "Build the sysvsem extension as a shared library"
  OFF
  "EXT_SYSVSEM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVSEM)
  return()
endif()

if(EXT_SYSVSEM_SHARED)
  add_library(php_sysvsem SHARED)
else()
  add_library(php_sysvsem)
endif()

target_sources(
  php_sysvsem
  PRIVATE
    sysvsem.c
    sysvsem.stub.php
)

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/types.h;sys/ipc.h;sys/sem.h")
  check_type_size("union semun" SEMUN)
cmake_pop_check_state()

set(HAVE_SYSVSEM 1)

configure_file(config.cmake.h.in config.h)
