include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_FIREBIRD
  "Enable the pdo_firebird extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info(
  "ext/pdo_firebird"
  EXT_PDO_FIREBIRD
  "Firebird database support in PDO (PHP Data Objects) interface"
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

target_sources(
  php_pdo_firebird
  PRIVATE
    firebird_driver.c
    firebird_statement.c
    pdo_firebird.c
)

add_dependencies(php_pdo_firebird php_pdo)

find_package(Firebird)
set_package_properties(
  Firebird
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_firebird extension."
)

target_link_libraries(php_pdo_firebird PRIVATE Firebird::Firebird)
