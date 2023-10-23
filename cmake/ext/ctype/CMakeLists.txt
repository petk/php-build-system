include(CMakeDependentOption)

option(EXT_CTYPE "Enable the ctype extension" ON)

cmake_dependent_option(
  EXT_CTYPE_SHARED
  "Build the ctype extension as a shared library"
  OFF
  "EXT_CTYPE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_CTYPE)
  return()
endif()

if(EXT_CTYPE_SHARED)
  add_library(php_ctype SHARED)
else()
  add_library(php_ctype)
endif()

target_sources(php_ctype PRIVATE
  ctype.c
)
