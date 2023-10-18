include(CMakeDependentOption)

option(EXT_SHMOP "Whether to enable the shmop extension" OFF)

cmake_dependent_option(
  EXT_SHMOP_SHARED
  "Whether to build the shmop extension as shared object"
  OFF
  "EXT_SHMOP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SHMOP)
  return()
endif()

if(EXT_SHMOP_SHARED)
  set(_type "SHARED")
endif()

add_library(php_shmop ${_type}
  shmop.c
)
