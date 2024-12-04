#[=============================================================================[
# The sysvmsg extension

Configure the `sysvmsg` extension.

This extension provides support for using System V message based IPC
(Interprocess Communication Mechanisms).

> [!NOTE]
> This extension is available only on \*nix systems.

## EXT_SYSVMSG

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_SYSVMSG_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionSysVmsg
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFile)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SYSVMSG "Enable the sysvmsg extension")

add_feature_info(
  "ext/sysvmsg"
  EXT_SYSVMSG
  "System V message based IPC support"
)

cmake_dependent_option(
  EXT_SYSVMSG_SHARED
  "Build the sysvmsg extension as a shared library"
  OFF
  "EXT_SYSVMSG;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVMSG)
  return()
endif()

check_include_file(sys/msg.h _HAVE_SYS_MSG_H)

if(NOT _HAVE_SYS_MSG_H)
  message(
    FATAL_ERROR
    "Cannot enable sysvmsg extension (System V IPC support). The sys/msg.h is "
    "missing."
  )
endif()

if(EXT_SYSVMSG_SHARED)
  add_library(php_sysvmsg SHARED)
else()
  add_library(php_sysvmsg)
endif()

target_sources(
  php_sysvmsg
  PRIVATE
    sysvmsg.c
    sysvmsg.stub.php
)

set(HAVE_SYSVMSG TRUE)

configure_file(cmake/config.h.in config.h)
