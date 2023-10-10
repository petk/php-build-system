include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_ODBC "Whether to enable the pdo_odbc extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_ODBC_SHARED "Whether to build the pdo_odbc extension as shared object" OFF "EXT_PDO_ODBC;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_ODBC)
  return()
endif()

if(EXT_PDO_ODBC_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pdo_odbc" ${_library_type})

#add_library(php_pdo_odbc ${_library_type})
