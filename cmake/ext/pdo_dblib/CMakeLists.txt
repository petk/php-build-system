include(CMakeDependentOption)

option(EXT_PDO_DBLIB "Whether to enable the pdo_dblib extension" OFF)

cmake_dependent_option(
  EXT_PDO_DBLIB_SHARED
  "Whether to build the pdo_dblib extension as shared object"
  OFF
  "EXT_PDO_DBLIB;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_DBLIB)
  return()
endif()

if(NOT EXT_PDO_DBLIB_SHARED AND EXT_PDO_SHARED)
  set(EXT_PDO_DBLIB_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_DBLIB_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#add_library(php_pdo_dblib ${_library_type})

#set_target_properties(php_pdo_dblib PROPERTIES PHP_EXT_DEPENDS php_pdo)
