include(CMakeDependentOption)

option(EXT_CTYPE "Whether to enable the ctype extension" ON)

cmake_dependent_option(
  EXT_CTYPE_SHARED
  "Whether to build the ctype extension as shared object"
  OFF
  "EXT_CTYPE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_CTYPE)
  return()
endif()

if(EXT_CTYPE_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_ctype ${_library_type}
  ctype.c
)
