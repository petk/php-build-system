include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_OCI
  "Enable the pdo_oci extension"
  OFF
  "EXT_PDO"
  OFF
)

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
  add_library(php_pdo_oci SHARED)
else()
  add_library(php_pdo_oci)
endif()

#[[
target_sources(php_pdo_oci PRIVATE
  ...
)

set_target_properties(
  php_pdo_oci
  PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo
)

target_include_directories(
  php_pdo_oci
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
)
#]]
