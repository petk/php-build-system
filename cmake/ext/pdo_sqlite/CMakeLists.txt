#[=============================================================================[
# The pdo_sqlite extension

Configure the `pdo_sqlite` extension.

This extension provides PDO interface for using SQLite database.

## PHP_EXT_PDO_SQLITE

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PDO_SQLITE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PhpExtensionPdoSqlite
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_PDO_SQLITE "Enable the pdo_sqlite extension" ON)

add_feature_info(
  "ext/pdo_sqlite"
  PHP_EXT_PDO_SQLITE
  "SQLite database PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_SQLITE_SHARED
  "Build the pdo_sqlite extension as a shared library"
  OFF
  PHP_EXT_PDO_SQLITE
  OFF
)

if(NOT PHP_EXT_PDO_SQLITE)
  return()
endif()

if(PHP_EXT_PDO_SQLITE_SHARED)
  add_library(php_ext_pdo_sqlite MODULE)
else()
  add_library(php_ext_pdo_sqlite OBJECT)
endif()

target_sources(
  php_ext_pdo_sqlite
  PRIVATE
    pdo_sqlite.c
    pdo_sqlite.stub.php
    sqlite_driver.c
    sqlite_driver.stub.php
    sqlite_sql_parser.c
    sqlite_statement.c
)

add_dependencies(php_ext_pdo_sqlite php_ext_pdo)

find_package(SQLite3 ${PHP_SQLITE_MIN_VERSION})
set_package_properties(
  SQLite3
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_sqlite extension."
)

target_link_libraries(php_ext_pdo_sqlite PRIVATE SQLite::SQLite3)

if(TARGET SQLite::SQLite3)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES SQLite::SQLite3)

    check_symbol_exists(
      sqlite3_close_v2
      sqlite3.h
      PHP_EXT_PDO_SQLITE_HAVE_SQLITE3_CLOSE_V2
    )
    set(HAVE_SQLITE3_CLOSE_V2 ${PHP_EXT_PDO_SQLITE_HAVE_SQLITE3_CLOSE_V2})

    check_symbol_exists(
      sqlite3_column_table_name
      sqlite3.h
      PHP_EXT_PDO_SQLITE_HAVE_SQLITE3_COLUMN_TABLE_NAME
    )
    set(
      HAVE_SQLITE3_COLUMN_TABLE_NAME
      ${PHP_EXT_PDO_SQLITE_HAVE_SQLITE3_COLUMN_TABLE_NAME}
    )

    check_symbol_exists(
      sqlite3_load_extension
      sqlite3.h
      PHP_EXT_HAVE_SQLITE3_LOAD_EXTENSION
    )
    if(NOT PHP_EXT_HAVE_SQLITE3_LOAD_EXTENSION)
      set(PDO_SQLITE_OMIT_LOAD_EXTENSION TRUE)
    endif()
  cmake_pop_check_state()
endif()

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

configure_file(cmake/config.h.in config.h)
