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

project(
  PhpExtensionSqlite3
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
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
  "PHP_EXT_SQLITE3;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_SQLITE3)
  return()
endif()

if(PHP_EXT_SQLITE3_SHARED)
  add_library(php_ext_sqlite3 SHARED)
else()
  add_library(php_ext_sqlite3)
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
  check_library_exists(
    SQLite::SQLite3
    sqlite3_errstr
    ""
    HAVE_SQLITE3_ERRSTR
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_expanded_sql
    ""
    HAVE_SQLITE3_EXPANDED_SQL
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_load_extension
    ""
    HAVE_SQLITE3_LOAD_EXTENSION
  )

  if(NOT HAVE_SQLITE3_LOAD_EXTENSION)
    set(SQLITE_OMIT_LOAD_EXTENSION TRUE)
  endif()
endif()

set(HAVE_SQLITE3 TRUE)

configure_file(cmake/config.h.in config.h)
