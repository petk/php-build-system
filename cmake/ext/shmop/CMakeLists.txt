include(CMakeDependentOption)

option(EXT_SHMOP "Whether to enable the shmop extension" OFF)

cmake_dependent_option(EXT_SHMOP_SHARED "Whether to build the shmop extension as shared object" OFF "EXT_SHMOP;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SHMOP)
  return()
endif()

if(EXT_SHMOP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "shmop" ${_library_type})

add_library(ext_shmop ${_library_type}
  shmop.c
)
