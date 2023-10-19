include(CMakeDependentOption)

option(EXT_SYSVSHM "Enable the sysvshm extension" OFF)

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
  set(_type "SHARED")
endif()

add_library(php_sysvshm ${_type}
  sysvshm.c
)
