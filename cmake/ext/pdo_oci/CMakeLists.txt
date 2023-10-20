include(CMakeDependentOption)

option(EXT_PDO_OCI "Enable the pdo_oci extension" OFF)

cmake_dependent_option(
  EXT_PDO_OCI_SHARED
  "Build the pdo_oci extension as a shared library"
  OFF
  "EXT_PDO_OCI;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_OCI)
  return()
endif()

if(EXT_PDO_OCI_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_oci ${_type})

#set_target_properties(php_pdo_oci PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo)
