#[=============================================================================[
# The pgsql extension

This extension provides support for using PostgreSQL database.

## Configuration options

### PHP_EXT_PGSQL

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PGSQL
  LANGUAGES C
)

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_PGSQL "Enable the pgsql extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/pgsql"
  PHP_EXT_PGSQL
  "PostgreSQL database support"
)

if(NOT PHP_EXT_PGSQL)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pgsql)

if(PHP_EXT_PGSQL STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_pgsql MODULE)
else()
  add_library(php_ext_pgsql OBJECT)
endif()

target_sources(
  php_ext_pgsql
  PRIVATE
    pgsql.c
    pgsql.stub.php
)

target_include_directories(php_ext_pgsql PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_pgsql
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Windows>:PGSQL_EXPORTS>
)

set_property(
  TARGET php_ext_pgsql
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pcre
)

include(PHP/Package/PostgreSQL)
find_package(PostgreSQL ${PHP_PACKAGE_POSTGRESQL_MIN_VERSION})
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
    check_symbol_exists(
      PQencryptPasswordConn
      libpq-fe.h
      PHP_EXT_HAVE_LIBPQ_SANITY_CHECK
    )
    if(NOT PHP_EXT_HAVE_LIBPQ_SANITY_CHECK)
      message(
        FATAL_ERROR
        "PostgreSQL check failed: libpq ${PHP_PACKAGE_POSTGRESQL_MIN_VERSION} "
        "or later is required."
      )
    endif()

    # Available since PostgreSQL library version 12.
    if(PostgreSQL_VERSION VERSION_GREATER_EQUAL 12)
      check_symbol_exists(
        PQresultMemorySize
        libpq-fe.h
        PHP_EXT_HAVE_PG_RESULT_MEMORY_SIZE
      )
      set(HAVE_PG_RESULT_MEMORY_SIZE ${PHP_EXT_HAVE_PG_RESULT_MEMORY_SIZE})

      check_source_compiles(C [[
        #include <libpq-fe.h>
        int main(void) { PGVerbosity e = PQERRORS_SQLSTATE; (void)e; return 0; }
      ]] PHP_EXT_PGSQL_HAVE_PQERRORS_SQLSTATE)
      set(HAVE_PQERRORS_SQLSTATE ${PHP_EXT_PGSQL_HAVE_PQERRORS_SQLSTATE})
    endif()

    # Available since PostgreSQL library version 17.
    if(PostgreSQL_VERSION VERSION_GREATER_EQUAL 17)
      # Indicates the presence of PQchangePassword.
      check_symbol_exists(
        LIBPQ_HAS_CHANGE_PASSWORD
        libpq-fe.h
        PHP_EXT_PGSQL_HAVE_LIBPQ_HAS_CHANGE_PASSWORD
      )
      check_symbol_exists(
        PQchangePassword
        libpq-fe.h
        PHP_EXT_PGSQL_HAVE_PQCHANGEPASSWORD
      )
      if(
        PHP_EXT_PGSQL_HAVE_LIBPQ_HAS_CHANGE_PASSWORD
        AND PHP_EXT_PGSQL_HAVE_PQCHANGEPASSWORD
      )
        set(HAVE_PG_CHANGE_PASSWORD TRUE)
      endif()

      # Indicates the presence of PQsocketPoll, PQgetCurrentTimeUSec.
      check_symbol_exists(
        LIBPQ_HAS_SOCKET_POLL
        libpq-fe.h
        PHP_EXT_PGSQL_HAVE_LIBPQ_HAS_SOCKET_POLL
      )
      check_symbol_exists(
        PQsocketPoll
        libpq-fe.h
        PHP_EXT_PGSQL_HAVE_PQSOCKETPOLL
      )
      if(
        PHP_EXT_PGSQL_HAVE_LIBPQ_HAS_SOCKET_POLL
        AND PHP_EXT_PGSQL_HAVE_PQSOCKETPOLL
      )
        set(HAVE_PG_SOCKET_POLL TRUE)
      endif()

      # Indicates the presence of PQsetChunkedRowsMode and PGRES_TUPLES_CHUNK.
      check_symbol_exists(
        LIBPQ_HAS_CHUNK_MODE
        libpq-fe.h
        PHP_EXT_PGSQL_HAVE_LIBPQ_HAS_CHUNK_MODE
      )
      check_symbol_exists(
        PQsetChunkedRowsMode
        libpq-fe.h
        PHP_EXT_PGSQL_HAVE_PQSETCHUNKEDROWSMODE
      )
      if(
        PHP_EXT_PGSQL_HAVE_LIBPQ_HAS_CHUNK_MODE
        AND PHP_EXT_PGSQL_HAVE_PQSETCHUNKEDROWSMODE
      )
        set(HAVE_PG_SET_CHUNKED_ROWS_SIZE TRUE)
      endif()

      # Indicates the presence of PQclosePrepared, PQclosePortal, etc.
      check_symbol_exists(
        LIBPQ_HAS_CLOSE_PREPARED
        "libpq-fe.h"
        PHP_EXT_HAVE_LIBPQ_HAS_CLOSE_PREPARED
      )
      check_symbol_exists(
        PQclosePrepared
        "libpq-fe.h"
        PHP_EXT_HAVE_PQCLOSEPREPARED
      )
      if(PHP_EXT_HAVE_LIBPQ_HAS_CLOSE_PREPARED AND PHP_EXT_HAVE_PQCLOSEPREPARED)
        set(HAVE_PG_CLOSE_STMT TRUE)
      endif()
    endif()

    # Available since PostgreSQL library version 18.
    if(PostgreSQL_VERSION VERSION_GREATER_EQUAL 18)
      # Indicates the presence of PQservice.
      check_symbol_exists(
        PQservice
        "libpq-fe.h"
        PHP_EXT_PGSQL_HAVE_PG_SERVICE
      )
      set(HAVE_PG_SERVICE ${PHP_EXT_PGSQL_HAVE_PG_SERVICE})
    endif()
  cmake_pop_check_state()
endif()

set(HAVE_PGSQL TRUE)

configure_file(cmake/config.h.in config.h)
