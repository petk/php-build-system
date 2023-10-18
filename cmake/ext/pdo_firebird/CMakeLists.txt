include(CMakeDependentOption)

option(EXT_PDO_FIREBIRD "Whether to enable the pdo_firebird extension" OFF)

cmake_dependent_option(
  EXT_PDO_FIREBIRD_SHARED
  "Whether to build the pdo_firebird extension as shared object"
  OFF
  "EXT_PDO_FIREBIRD;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_FIREBIRD)
  return()
endif()

if(NOT EXT_PDO_FIREBIRD_SHARED AND EXT_PDO_SHARED)
  set(EXT_PDO_FIREBIRD_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_FIREBIRD_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_pdo_firebird ${_type})

#set_target_properties(php_pdo_firebird PROPERTIES PHP_EXT_DEPENDS php_pdo)
