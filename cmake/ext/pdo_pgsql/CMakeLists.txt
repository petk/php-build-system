#[=============================================================================[
# The pdo_pgsql extension

Configure the `pdo_pgsql` extension.

This extension provides PDO interface for using PostgreSQL database.

## EXT_PDO_PGSQL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_PDO_PGSQL_SHARED

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

option(EXT_PDO_PGSQL "Enable the pdo_pgsql extension")

add_feature_info(
  "ext/pdo_pgsql"
  EXT_PDO_PGSQL
  "PostgreSQL database support in PDO"
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
    pgsql_driver.c
    pgsql_driver.stub.php
    pgsql_statement.c
)

add_dependencies(php_pdo_pgsql php_pdo)

target_include_directories(
  php_pdo_pgsql
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

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
  check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _PHP_LIBPQ_CHECK)
  if(NOT _PHP_LIBPQ_CHECK)
    message(
      FATAL_ERROR
      "PostgreSQL check failed: libpq ${PHP_POSTGRESQL_MIN_VERSION} or later "
      "is required, please see CMake logs for details."
    )
  endif()
endif()

set(HAVE_PDO_PGSQL TRUE)

configure_file(config.cmake.h.in config.h)
