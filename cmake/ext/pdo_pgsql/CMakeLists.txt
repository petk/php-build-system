#[=============================================================================[
# The pdo_pgsql extension

Configure the `pdo_pgsql` extension.

This extension provides PDO interface for using PostgreSQL database.

## PHP_EXT_PDO_PGSQL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PDO_PGSQL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPdoPgsql
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_PDO_PGSQL "Enable the pdo_pgsql extension")

add_feature_info(
  "ext/pdo_pgsql"
  PHP_EXT_PDO_PGSQL
  "PostgreSQL database PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_PGSQL_SHARED
  "Build the pdo_pgsql extension as a shared library"
  OFF
  "PHP_EXT_PDO_PGSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PDO_PGSQL)
  return()
endif()

if(PHP_EXT_PDO_PGSQL_SHARED)
  add_library(php_ext_pdo_pgsql SHARED)
else()
  add_library(php_ext_pdo_pgsql)
endif()

target_sources(
  php_ext_pdo_pgsql
  PRIVATE
    pdo_pgsql.c
    pdo_pgsql.stub.php
    pgsql_driver.c
    pgsql_driver.stub.php
    pgsql_sql_parser.c
    pgsql_statement.c
)

add_dependencies(php_ext_pdo_pgsql php_ext_pdo)

find_package(PostgreSQL ${PHP_POSTGRESQL_MIN_VERSION})
set_package_properties(
  PostgreSQL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_pgsql extension."
)

target_link_libraries(php_ext_pdo_pgsql PUBLIC PostgreSQL::PostgreSQL)

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
      "is required."
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

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

set(HAVE_PDO_PGSQL TRUE)

configure_file(cmake/config.h.in config.h)
