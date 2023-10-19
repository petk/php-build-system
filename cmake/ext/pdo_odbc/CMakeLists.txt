include(CMakeDependentOption)

option(EXT_PDO_ODBC "Enable the pdo_odbc extension" OFF)

cmake_dependent_option(
  EXT_PDO_ODBC_SHARED
  "Build the pdo_odbc extension as a shared library"
  OFF
  "EXT_PDO_ODBC;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_ODBC)
  return()
endif()

if(NOT EXT_PDO_ODBC_SHARED AND EXT_PDO_SHARED)
  set(EXT_PDO_ODBC_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_ODBC_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_odbc ${_type})

#set_target_properties(php_pdo_odbc PROPERTIES PHP_EXT_DEPENDS php_pdo)
