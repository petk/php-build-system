#[=============================================================================[
# The pdo_pgsql extension

This extension provides PDO interface for using PostgreSQL database.

## Configuration options

### PHP_EXT_PDO_PGSQL

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PDO_PGSQL
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_PDO_PGSQL "Enable the pdo_pgsql extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/pdo_pgsql"
  PHP_EXT_PDO_PGSQL
  "PostgreSQL database PDO driver"
)

if(NOT PHP_EXT_PDO_PGSQL)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo_pgsql)

if(PHP_EXT_PDO_PGSQL STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_pdo_pgsql MODULE)
else()
  add_library(php_ext_pdo_pgsql OBJECT)
endif()

target_sources(
  php_ext_pdo_pgsql
  PRIVATE
    pdo_pgsql.c
    pgsql_driver.c
    pgsql_driver.stub.php
    pgsql_statement.c
)

set_property(
  TARGET php_ext_pdo_pgsql
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pdo
)

target_include_directories(
  php_ext_pdo_pgsql
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

include(PHP/Package/PostgreSQL)
find_package(PostgreSQL ${PHP_PACKAGE_POSTGRESQL_MIN_VERSION})
set_package_properties(
  PostgreSQL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_pgsql extension."
)

target_link_libraries(php_ext_pdo_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Check PostgreSQL library (libpq) features.
if(TARGET PostgreSQL::PostgreSQL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES PostgreSQL::PostgreSQL)

    # PostgreSQL library minimum version sanity check.
    check_symbol_exists(PQlibVersion libpq-fe.h PHP_EXT_HAVE_LIBPQ_SANITY_CHECK)
    if(NOT PHP_EXT_HAVE_LIBPQ_SANITY_CHECK)
      message(
        FATAL_ERROR
        "PostgreSQL check failed: libpq ${PHP_PACKAGE_POSTGRESQL_MIN_VERSION} "
        "or later is required."
      )
    endif()
  cmake_pop_check_state()
endif()

set(HAVE_PDO_PGSQL TRUE)

configure_file(cmake/config.h.in config.h)
