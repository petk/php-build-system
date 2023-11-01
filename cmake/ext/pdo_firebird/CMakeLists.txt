include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_FIREBIRD
  "Enable the pdo_firebird extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info("ext/pdo_firebird" EXT_PDO_FIREBIRD
  "Adds support for Firebird database to PDO (PHP Data Objects) interface."
)

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
  add_library(php_pdo_firebird SHARED)
else()
  add_library(php_pdo_firebird)
endif()

target_sources(php_pdo_firebird PRIVATE
  firebird_driver.c
  firebird_statement.c
  pdo_firebird.c
)

set_target_properties(
  php_pdo_firebird
  PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo
)

target_include_directories(
  php_pdo_firebird
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

find_package(Firebird)
set_package_properties(Firebird PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the pdo_firebird extension."
)

target_link_libraries(php_pdo_firebird PRIVATE Firebird::Firebird)
