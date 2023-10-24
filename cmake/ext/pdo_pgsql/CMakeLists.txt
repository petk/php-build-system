include(CMakeDependentOption)

cmake_dependent_option(
  EXT_PDO_PGSQL
  "Enable the pdo_pgsql extension"
  OFF
  "EXT_PDO"
  OFF
)

cmake_dependent_option(
  EXT_PDO_PGSQL_SHARED
  "Build the pdo_pgsql extension as a shared library"
  OFF
  "EXT_PDO_PGSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_PGSQL)
  return()
endif()

if(EXT_PDO_PGSQL_SHARED)
  add_library(php_pdo_pgsql SHARED)
else()
  add_library(php_pdo_pgsql)
endif()

target_sources(php_pdo_pgsql PRIVATE
  pdo_pgsql.c
  pgsql_driver.c
  pgsql_statement.c
)

set_target_properties(
  php_pdo_pgsql
  PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo
)

target_include_directories(
  php_pdo_pgsql
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

find_package(PostgreSQL 9.1 REQUIRED)

target_link_libraries(php_pdo_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Sanity check.
check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _have_pqlibversion)

if(NOT _have_pqlibversion)
  message(FATAL_ERROR "PQlibVersion could not be found. Something is wrong with the libpq library. See the logs.")
endif()
