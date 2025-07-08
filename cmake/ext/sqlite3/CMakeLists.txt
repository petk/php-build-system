#[=============================================================================[
# The sqlite3 extension

Configure the `sqlite3` extension.

This extension provides support for using SQLite database.

## PHP_EXT_SQLITE3

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SQLITE3_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionSqlite3
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_SQLITE3 "Enable the sqlite3 extension" ON)

add_feature_info(
  "ext/sqlite3"
  PHP_EXT_SQLITE3
  "SQLite database support"
)

cmake_dependent_option(
  PHP_EXT_SQLITE3_SHARED
  "Build the sqlite3 extension as a shared library"
  OFF
  PHP_EXT_SQLITE3
  OFF
)

if(NOT PHP_EXT_SQLITE3)
  return()
endif()

if(PHP_EXT_SQLITE3_SHARED)
  add_library(php_ext_sqlite3 MODULE)
else()
  add_library(php_ext_sqlite3 OBJECT)
endif()

target_sources(
  php_ext_sqlite3
  PRIVATE
    sqlite3.c
    sqlite3.stub.php
)

target_compile_definitions(php_ext_sqlite3 PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(SQLite3 ${PHP_SQLITE_MIN_VERSION})
set_package_properties(
  SQLite3
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the sqlite3 extension."
)

target_link_libraries(php_ext_sqlite3 PRIVATE SQLite::SQLite3)

if(TARGET SQLite::SQLite3)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES SQLite::SQLite3)

    check_symbol_exists(sqlite3_expanded_sql sqlite3.h HAVE_SQLITE3_EXPANDED_SQL)

    check_symbol_exists(
      sqlite3_load_extension
      sqlite3.h
      PHP_HAS_SQLITE3_LOAD_EXTENSION
    )
    if(NOT PHP_HAS_SQLITE3_LOAD_EXTENSION)
      set(SQLITE_OMIT_LOAD_EXTENSION TRUE)
    endif()
  cmake_pop_check_state()
endif()

set(HAVE_SQLITE3 TRUE)

configure_file(cmake/config.h.in config.h)
