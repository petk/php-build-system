include(CMakeDependentOption)

option(EXT_PDO_FIREBIRD "Enable the pdo_firebird extension" OFF)

cmake_dependent_option(
  EXT_PDO_FIREBIRD_SHARED
  "Build the pdo_firebird extension as a shared library"
  OFF
  "EXT_PDO_FIREBIRD;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_FIREBIRD)
  return()
endif()

if(EXT_PDO_FIREBIRD_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_firebird ${_type})

#set_target_properties(php_pdo_firebird PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo)
