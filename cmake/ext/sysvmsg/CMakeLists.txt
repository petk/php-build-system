include(CheckIncludeFile)
include(CMakeDependentOption)

option(EXT_SYSVMSG "Whether to enable the sysvmsg extension" OFF)

cmake_dependent_option(
  EXT_SYSVMSG_SHARED
  "Whether to build the sysvmsg extension as shared object"
  OFF
  "EXT_SYSVMSG;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVMSG)
  return()
endif()

check_include_file(sys/msg.h HAVE_SYS_MSG_H)

if(NOT HAVE_SYS_MSG_H)
  message(FATAL_ERROR "Cannot enable System V IPC support, sys/msg.h is missing")
endif()

if(EXT_SYSVMSG_SHARED)
  set(_type "SHARED")
endif()

add_library(php_sysvmsg ${_type}
  sysvmsg.c
)
