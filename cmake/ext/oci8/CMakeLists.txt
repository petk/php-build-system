include(CMakeDependentOption)

option(EXT_OCI8 "Enable the oci8 extension" OFF)

cmake_dependent_option(
  EXT_OCI8_SHARED
  "Build the oci8 extension as a shared library"
  OFF
  "EXT_OCI8;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_OCI8)
  return()
endif()

if(EXT_OCI8_SHARED)
  add_library(php_oci8 SHARED)
else()
  add_library(php_oci8)
endif()

#target_sources(php_oci8 PRIVATE
  #...
#)
