include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_DBLIB "Whether to enable the pdo_dblib extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_DBLIB_SHARED "Whether to build the pdo_dblib extension as shared object" OFF "EXT_PDO_DBLIB;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_DBLIB)
  return()
endif()

if(EXT_PDO_DBLIB_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pdo_dblib" ${_library_type})

#add_library(pdo_dblib ${_library_type})
