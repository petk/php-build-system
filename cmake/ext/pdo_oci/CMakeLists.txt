include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_OCI
  "Whether to enable the pdo_oci extension"
  OFF
  "EXT_PDO"
  OFF
)

cmake_dependent_option(
  EXT_PDO_OCI_SHARED
  "Whether to build the pdo_oci extension as shared object"
  OFF
  "EXT_PDO_OCI;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_OCI)
  return()
endif()

if(NOT EXT_PDO_OCI_SHARED AND EXT_PDO_SHARED)
  set(EXT_PDO_OCI_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_OCI_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_oci ${_type})

#set_target_properties(php_pdo_oci PROPERTIES PHP_EXT_DEPENDS php_pdo)
