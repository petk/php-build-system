include(CMakeDependentOption)

option(EXT_OCI8 "Whether to enable the OCI8 extension" OFF)

cmake_dependent_option(
  EXT_OCI8_SHARED
  "Whether to build the OCI8 extension as shared object"
  OFF
  "EXT_OCI8;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_OCI8)
  return()
endif()

if(EXT_OCI8_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#add_library(php_oci8 ${_library_type})
