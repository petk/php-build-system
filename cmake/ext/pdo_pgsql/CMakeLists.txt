project(
  PhpExtensionPdoPgsql
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_PGSQL
  "Enable the pdo_pgsql extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info(
  "ext/pdo_pgsql"
  EXT_PDO_PGSQL
  "PostgreSQL database support in PDO (PHP Data Objects)"
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

target_sources(
  php_pdo_pgsql
  PRIVATE
    pdo_pgsql.c
    pdo_pgsql.stub.php
    pgsql_driver.c
    pgsql_driver.stub.php
    pgsql_sql_parser.c
    pgsql_statement.c
)

add_dependencies(php_pdo_pgsql php_pdo)

find_package(PostgreSQL ${PHP_POSTGRESQL_MIN_VERSION})
set_package_properties(
  PostgreSQL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_pgsql extension."
)

target_link_libraries(php_pdo_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Sanity check.
if(TARGET PostgreSQL::PostgreSQL)
  # PostgreSQL library minimum version sanity check.
  check_library_exists(
    PostgreSQL::PostgreSQL
    PQencryptPasswordConn
    ""
    _PHP_LIBPQ_CHECK
  )
  if(NOT _PHP_LIBPQ_CHECK)
    message(
      FATAL_ERROR
      "PostgreSQL check failed: libpq ${PHP_POSTGRESQL_MIN_VERSION} or later "
      "is required, please see CMake logs for details."
    )
  endif()

  if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 12)
    check_library_exists(
      PostgreSQL::PostgreSQL
      PQresultMemorySize
      ""
      HAVE_PG_RESULT_MEMORY_SIZE
    )
  endif()

  # Available since PostgreSQL 17.
  if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 17)
    check_library_exists(
      PostgreSQL::PostgreSQL
      PQclosePrepared
      ""
      HAVE_PQCLOSEPREPARED
    )
  endif()
endif()

if(RE2C_FOUND)
  re2c_target(
    php_pdo_pgsql_sql_parser
    pgsql_sql_parser.re
    ${CMAKE_CURRENT_SOURCE_DIR}/pgsql_sql_parser.c
  )
endif()

set(HAVE_PDO_PGSQL 1)

configure_file(config.cmake.h.in config.h @ONLY)
