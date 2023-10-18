include(CMakeDependentOption)

option(EXT_PDO_PGSQL "Whether to enable the pdo_pgsql extension" OFF)

cmake_dependent_option(
  EXT_PDO_PGSQL_SHARED
  "Whether to build the pdo_pgsql extension as shared object"
  OFF
  "EXT_PDO_PGSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_PGSQL)
  return()
endif()

if(NOT EXT_PDO_PGSQL_SHARED AND EXT_PDO_SHARED)
  set(EXT_PDO_PGSQL_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_PGSQL_SHARED)
  set(_type "SHARED")
endif()

add_library(php_pdo_pgsql ${_type}
  pdo_pgsql.c
  pgsql_driver.c
  pgsql_statement.c
)

set_target_properties(php_pdo_pgsql PROPERTIES PHP_EXT_DEPENDS php_pdo)

target_include_directories(php_pdo_pgsql PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")

find_package(PostgreSQL 9.1 REQUIRED)

target_link_libraries(php_pdo_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Sanity check.
check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _have_pqlibversion)

if(NOT _have_pqlibversion)
  message(FATAL_ERROR "PQlibVersion could not be found. Something is wrong with the libpq library. See the logs.")
endif()
