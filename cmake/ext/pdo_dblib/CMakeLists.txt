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

if(EXT_PDO_DBLIB_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_dblib ${_type})

#set_target_properties(php_pdo_dblib PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo)
