include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_FIREBIRD
  "Enable the pdo_firebird extension"
  OFF
  "EXT_PDO"
  OFF
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
  pdo_firebird.c
  firebird_driver.c
  firebird_statement.c
)

set_target_properties(
  php_pdo_firebird
  PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo
)

target_include_directories(
  php_pdo_firebird
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

find_package(Firebird REQUIRED)

target_link_libraries(php_pdo_firebird PRIVATE Firebird::Firebird)
