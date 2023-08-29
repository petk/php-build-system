include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_OCI "Whether to enable the pdo_oci extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_OCI_SHARED "Whether to build the pdo_oci extension as shared object" OFF "EXT_PDO_OCI;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_OCI)
  return()
endif()

if(EXT_PDO_OCI_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pdo_oci" ${_library_type})

#add_library(ext_pdo_oci ${_library_type})
