include(CheckIncludeFile)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SYSVMSG "Enable the sysvmsg extension" OFF)

add_feature_info("ext/sysvmsg" EXT_SYSVMSG
  "Adds support for the System V IPC."
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

if(EXT_SYSVMSG_SHARED)
  add_library(php_sysvmsg SHARED)
else()
  add_library(php_sysvmsg)
endif()

target_sources(php_sysvmsg PRIVATE
  sysvmsg.c
)

check_include_file(sys/msg.h HAVE_SYS_MSG_H)

if(NOT HAVE_SYS_MSG_H)
  message(FATAL_ERROR "Cannot enable System V IPC support, sys/msg.h is missing")
endif()
