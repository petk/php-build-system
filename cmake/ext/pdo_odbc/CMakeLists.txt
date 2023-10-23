include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_ODBC
  "Enable the pdo_odbc extension"
  OFF
  "EXT_PDO"
  OFF
)

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

if(EXT_PDO_ODBC_SHARED)
  add_library(php_pdo_odbc SHARED)
else()
  add_library(php_pdo_odbc)
endif()

#target_sources(php_pdo_odbc PRIVATE
  #...
#)

#set_target_properties(php_pdo_odbc PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo)
