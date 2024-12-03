#[=============================================================================[
# The pdo_sqlite extension

Configure the `pdo_sqlite` extension.

This extension provides PDO interface for using SQLite database.

## EXT_PDO_SQLITE

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_PDO_SQLITE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPdoSqlite
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO_SQLITE "Enable the pdo_sqlite extension" ON)

add_feature_info(
  "ext/pdo_sqlite"
  EXT_PDO_SQLITE
  "SQLite database PDO driver"
)

cmake_dependent_option(
  EXT_PDO_SQLITE_SHARED
  "Build the pdo_sqlite extension as a shared library"
  OFF
  "EXT_PDO_SQLITE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_SQLITE)
  return()
endif()

if(EXT_PDO_SQLITE_SHARED)
  add_library(php_pdo_sqlite SHARED)
else()
  add_library(php_pdo_sqlite)
endif()

target_sources(
  php_pdo_sqlite
  PRIVATE
    pdo_sqlite.c
    pdo_sqlite.stub.php
    sqlite_driver.c
    sqlite_driver.stub.php
    sqlite_sql_parser.c
    sqlite_statement.c
)

add_dependencies(php_pdo_sqlite php_pdo)

find_package(SQLite3 ${PHP_SQLITE_MIN_VERSION})
set_package_properties(
  SQLite3
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_sqlite extension."
)

target_link_libraries(php_pdo_sqlite PRIVATE SQLite::SQLite3)

if(TARGET SQLite::SQLite3)
  check_library_exists(
    SQLite::SQLite3
    sqlite3_close_v2
    ""
    HAVE_SQLITE3_CLOSE_V2
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_column_table_name
    ""
    HAVE_SQLITE3_COLUMN_TABLE_NAME
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_load_extension
    ""
    HAVE_SQLITE3_LOAD_EXTENSION
  )

  if(NOT HAVE_SQLITE3_LOAD_EXTENSION)
    set(PDO_SQLITE_OMIT_LOAD_EXTENSION TRUE)
  endif()
endif()

if(RE2C_FOUND)
  re2c_target(
    php_pdo_sqlite_sql_parser
    sqlite_sql_parser.re
    ${CMAKE_CURRENT_SOURCE_DIR}/sqlite_sql_parser.c
  )
endif()

configure_file(config.cmake.h.in config.h)
