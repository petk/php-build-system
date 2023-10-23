include(CMakeDependentOption)

option(EXT_SHMOP "Enable the shmop extension" OFF)

cmake_dependent_option(
  EXT_SHMOP_SHARED
  "Build the shmop extension as a shared library"
  OFF
  "EXT_SHMOP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SHMOP)
  return()
endif()

if(EXT_SHMOP_SHARED)
  add_library(php_shmop SHARED)
else()
  add_library(php_shmop)
endif()

target_sources(php_shmop PRIVATE
  shmop.c
)
