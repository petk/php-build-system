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
    HAVE_PQFREEMEM # PQfreemem is available since PostgreSQL library 7.4.
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
    check_symbol_exists(PQlibVersion libpq-fe.h PHP_EXT_HAVE_LIBPQ_SANITY_CHECK)
    if(NOT PHP_EXT_HAVE_LIBPQ_SANITY_CHECK)
      message(
        FATAL_ERROR
        "PostgreSQL check failed: libpq ${PHP_PACKAGE_POSTGRESQL_MIN_VERSION} "
        "or later is required."
      )
    endif()

    check_symbol_exists(
      pg_encoding_to_char
      libpq-fe.h
      PHP_EXT_PGSQL_HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT
    )
    set(
      HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT
      ${PHP_EXT_PGSQL_HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT}
    )

    check_symbol_exists(
      lo_truncate64
      libpq-fe.h
      PHP_EXT_PGSQL_HAVE_PG_LO64
    )
    set(HAVE_PG_LO64 ${PHP_EXT_PGSQL_HAVE_PG_LO64})

    check_symbol_exists(
      PQsetErrorContextVisibility
      libpq-fe.h
      PHP_EXT_PGSQL_HAVE_PG_CONTEXT_VISIBILITY
    )
    set(HAVE_PG_CONTEXT_VISIBILITY ${PHP_EXT_PGSQL_HAVE_PG_CONTEXT_VISIBILITY})
  cmake_pop_check_state()
endif()

set(HAVE_PGSQL TRUE)

configure_file(cmake/config.h.in config.h)
