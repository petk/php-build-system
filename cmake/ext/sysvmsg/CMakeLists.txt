#[=============================================================================[
# The sysvmsg extension

Configure the `sysvmsg` extension.

This extension provides support for using System V message based IPC
(Interprocess Communication Mechanisms).

> [!NOTE]
> This extension is available only on \*nix systems.

## PHP_EXT_SYSVMSG

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SYSVMSG_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionSysVmsg
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFiles)
include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_SYSVMSG "Enable the sysvmsg extension")

add_feature_info(
  "ext/sysvmsg"
  PHP_EXT_SYSVMSG
  "System V message based IPC support"
)

cmake_dependent_option(
  PHP_EXT_SYSVMSG_SHARED
  "Build the sysvmsg extension as a shared library"
  OFF
  PHP_EXT_SYSVMSG
  OFF
)

if(NOT PHP_EXT_SYSVMSG)
  return()
endif()

check_include_files(sys/msg.h PHP_EXT_SYSVMSG_HAVE_SYS_MSG_H)

if(NOT PHP_EXT_SYSVMSG_HAVE_SYS_MSG_H)
  message(
    FATAL_ERROR
    "Cannot enable sysvmsg extension (System V IPC support). The sys/msg.h is "
    "missing."
  )
endif()

if(PHP_EXT_SYSVMSG_SHARED)
  add_library(php_ext_sysvmsg MODULE)
else()
  add_library(php_ext_sysvmsg OBJECT)
endif()

target_sources(
  php_ext_sysvmsg
  PRIVATE
    sysvmsg.c
    sysvmsg.stub.php
)

set(HAVE_SYSVMSG TRUE)

configure_file(cmake/config.h.in config.h)
