include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_PGSQL "Whether to enable the pdo_pgsql extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_PGSQL_SHARED "Whether to build the pdo_pgsql extension as shared object" OFF "EXT_PDO_PGSQL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_PGSQL)
  return()
endif()

if(EXT_PDO_PGSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pdo_pgsql" ${_library_type})

#add_library(ext_pdo_pgsql ${_library_type})
