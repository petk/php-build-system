#[=============================================================================[
# The pgsql extension

Configure the `pgsql` extension.

This extension provides support for using PostgreSQL database.

## EXT_PGSQL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_PGSQL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPgSql
  LANGUAGES C
)

include(CheckLibraryExists)
include(CheckSourceCompiles)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_PGSQL "Enable the pgsql extension")

add_feature_info(
  "ext/pgsql"
  EXT_PGSQL
  "PostgreSQL database support"
)

cmake_dependent_option(
  EXT_PGSQL_SHARED
  "Build the pgsql extension as a shared library"
  OFF
  "EXT_PGSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PGSQL)
  return()
endif()

if(EXT_PGSQL_SHARED)
  add_library(php_pgsql SHARED)
else()
  add_library(php_pgsql)
endif()

target_sources(
  php_pgsql
  PRIVATE
    pgsql.c
    pgsql.stub.php
)

target_compile_definitions(
  php_pgsql
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Windows>:PGSQL_EXPORTS>
)

add_dependencies(php_pgsql php_pcre)

find_package(PostgreSQL ${PHP_POSTGRESQL_MIN_VERSION})
set_package_properties(
  PostgreSQL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pgsql extension."
)

target_link_libraries(php_pgsql PUBLIC PostgreSQL::PostgreSQL)

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

  # Available since PostgreSQL 12.
  if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 12)
    check_library_exists(
      PostgreSQL::PostgreSQL
      PQresultMemorySize
      ""
      HAVE_PG_RESULT_MEMORY_SIZE
    )

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES PostgreSQL::PostgreSQL)
      check_source_compiles(C [[
        #include <libpq-fe.h>
        int main(void) { PGVerbosity e = PQERRORS_SQLSTATE; (void)e; return 0; }
      ]] HAVE_PQERRORS_SQLSTATE)
    cmake_pop_check_state()
  endif()

  # Available since PostgreSQL 17.
  if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 17)
    check_library_exists(
      PostgreSQL::PostgreSQL
      PQchangePassword
      ""
      HAVE_PG_CHANGE_PASSWORD
    )

    check_library_exists(
      PostgreSQL::PostgreSQL
      PQsocketPoll
      ""
      HAVE_PG_SOCKET_POLL
    )

    check_library_exists(
      PostgreSQL::PostgreSQL
      PQsetChunkedRowsMode
      ""
      HAVE_PG_SET_CHUNKED_ROWS_SIZE
    )

    check_library_exists(
      PostgreSQL::PostgreSQL
      PQclosePrepared
      ""
      HAVE_PG_CLOSE_STMT
    )
  endif()
endif()

set(HAVE_PGSQL TRUE)

configure_file(config.cmake.h.in config.h)
