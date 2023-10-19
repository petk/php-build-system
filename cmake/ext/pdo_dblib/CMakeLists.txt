include(CMakeDependentOption)

option(EXT_PDO_DBLIB "Enable the pdo_dblib extension" OFF)

cmake_dependent_option(
  EXT_PDO_DBLIB_SHARED
  "Build the pdo_dblib extension as a shared library"
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

if(EXT_PDO_DBLIB_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_dblib ${_type})

#set_target_properties(php_pdo_dblib PROPERTIES PHP_EXT_DEPENDS php_pdo)
