include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_FIREBIRD
  "Whether to enable the pdo_firebird extension"
  OFF
  "EXT_PDO"
  OFF
)

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

if(EXT_PDO_FIREBIRD_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pdo_firebird" ${_library_type})

#add_library(php_pdo_firebird ${_library_type})
