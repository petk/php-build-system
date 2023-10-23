include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_DBLIB
  "Enable the pdo_dblib extension"
  OFF
  "EXT_PDO"
  OFF
)

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
  add_library(php_pdo_dblib SHARED)
else()
  add_library(php_pdo_dblib)
endif()

#target_sources(php_pdo_dblib PRIVATE
  #...
#)

#set_target_properties(php_pdo_dblib PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo)
