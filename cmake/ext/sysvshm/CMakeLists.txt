include(CMakeDependentOption)

option(EXT_SYSVSHM "Whether to enable the sysvshm extension" OFF)

cmake_dependent_option(
  EXT_SYSVSHM_SHARED
  "Whether to build the sysvshm extension as shared object"
  OFF
  "EXT_SYSVSHM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVSHM)
  return()
endif()

if(EXT_SYSVSHM_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "sysvshm" ${_library_type})

add_library(php_sysvshm ${_library_type}
  sysvshm.c
)
