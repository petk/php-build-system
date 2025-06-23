#[=============================================================================[
# The pgsql extension

Configure the `pgsql` extension.

This extension provides support for using PostgreSQL database.

## PHP_EXT_PGSQL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PGSQL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  php_ext_pgsql
  LANGUAGES C
)

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_PGSQL "Enable the pgsql extension")

add_feature_info(
  "ext/pgsql"
  PHP_EXT_PGSQL
  "PostgreSQL database support"
)

cmake_dependent_option(
  PHP_EXT_PGSQL_SHARED
  "Build the pgsql extension as a shared library"
  OFF
  "PHP_EXT_PGSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PGSQL)
  return()
endif()

if(PHP_EXT_PGSQL_SHARED)
  add_library(php_ext_pgsql MODULE)
else()
  add_library(php_ext_pgsql)
endif()

target_sources(
  php_ext_pgsql
  PRIVATE
    pgsql.c
    pgsql.stub.php
)

target_compile_definitions(
  php_ext_pgsql
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Windows>:PGSQL_EXPORTS>
)

add_dependencies(php_ext_pgsql php_ext_pcre)

find_package(PostgreSQL ${PHP_POSTGRESQL_MIN_VERSION})
set_package_properties(
  PostgreSQL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pgsql extension."
)

target_link_libraries(php_ext_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Check PostgreSQL library (libpq) features.
if(TARGET PostgreSQL::PostgreSQL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES PostgreSQL::PostgreSQL)

    # PostgreSQL library minimum version sanity check.
    check_symbol_exists(PQencryptPasswordConn libpq-fe.h PHP_HAS_LIBPQ_SANITY_CHECK)
    if(NOT PHP_HAS_LIBPQ_SANITY_CHECK)
      message(
        FATAL_ERROR
        "PostgreSQL check failed: libpq ${PHP_POSTGRESQL_MIN_VERSION} or later "
        "is required."
      )
    endif()

    # Available since PostgreSQL library version 12.
    if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 12)
      check_symbol_exists(
        PQresultMemorySize
        libpq-fe.h
        HAVE_PG_RESULT_MEMORY_SIZE
      )

      check_source_compiles(C [[
        #include <libpq-fe.h>
        int main(void) { PGVerbosity e = PQERRORS_SQLSTATE; (void)e; return 0; }
      ]] HAVE_PQERRORS_SQLSTATE)
    endif()

    # Available since PostgreSQL library version 17.
    if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 17)
      # Indicates the presence of PQchangePassword.
      check_symbol_exists(
        LIBPQ_HAS_CHANGE_PASSWORD
        libpq-fe.h
        PHP_HAS_LIBPQ_HAS_CHANGE_PASSWORD
      )
      check_symbol_exists(
        PQchangePassword
        libpq-fe.h
        PHP_HAS_PQCHANGEPASSWORD
      )
      if(PHP_HAS_LIBPQ_HAS_CHANGE_PASSWORD AND PHP_HAS_PQCHANGEPASSWORD)
        set(HAVE_PG_CHANGE_PASSWORD TRUE)
      endif()

      # Indicates the presence of PQsocketPoll, PQgetCurrentTimeUSec.
      check_symbol_exists(
        LIBPQ_HAS_SOCKET_POLL
        libpq-fe.h
        PHP_HAS_LIBPQ_HAS_SOCKET_POLL
      )
      check_symbol_exists(
        PQsocketPoll
        libpq-fe.h
        PHP_HAS_PQSOCKETPOLL
      )
      if(PHP_HAS_LIBPQ_HAS_SOCKET_POLL AND PHP_HAS_PQSOCKETPOLL)
        set(HAVE_PG_SOCKET_POLL TRUE)
      endif()

      # Indicates the presence of PQsetChunkedRowsMode and PGRES_TUPLES_CHUNK.
      check_symbol_exists(
        LIBPQ_HAS_CHUNK_MODE
        libpq-fe.h
        PHP_HAS_LIBPQ_HAS_CHUNK_MODE
      )
      check_symbol_exists(
        PQsetChunkedRowsMode
        libpq-fe.h
        PHP_HAS_PQSETCHUNKEDROWSMODE
      )
      if(PHP_HAS_LIBPQ_HAS_CHUNK_MODE AND PHP_HAS_PQSETCHUNKEDROWSMODE)
        set(HAVE_PG_SET_CHUNKED_ROWS_SIZE TRUE)
      endif()

      # Indicates the presence of PQclosePrepared, PQclosePortal, etc.
      check_symbol_exists(
        LIBPQ_HAS_CLOSE_PREPARED
        "libpq-fe.h"
        PHP_HAS_LIBPQ_HAS_CLOSE_PREPARED
      )
      check_symbol_exists(
        PQclosePrepared
        "libpq-fe.h"
        PHP_HAS_PQCLOSEPREPARED
      )
      if(PHP_HAS_LIBPQ_HAS_CLOSE_PREPARED AND PHP_HAS_PQCLOSEPREPARED)
        set(HAVE_PG_CLOSE_STMT TRUE)
      endif()
    endif()

    # Available since PostgreSQL library version 18.
    if(PostgreSQL_VERSION_STRING VERSION_GREATER_EQUAL 18)
      # Indicates the presence of PQservice.
      check_symbol_exists(
        PQservice
        "libpq-fe.h"
        PHP_HAS_PQSERVICE
      )
      if(PHP_HAS_PQSERVICE)
        set(HAVE_PG_SERVICE TRUE)
      endif()
    endif()
  cmake_pop_check_state()
endif()

set(HAVE_PGSQL TRUE)

configure_file(cmake/config.h.in config.h)
