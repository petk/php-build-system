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

project(
  php_ext_pgsql
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
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
  add_library(php_ext_pgsql SHARED)
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

if(TARGET PostgreSQL::PostgreSQL)
  # PostgreSQL library minimum version sanity check.
  check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _PHP_LIBPQ_CHECK)
  if(NOT _PHP_LIBPQ_CHECK)
    message(
      FATAL_ERROR
      "PostgreSQL check failed: libpq ${PHP_POSTGRESQL_MIN_VERSION} or later "
      "is required."
    )
  endif()

  check_library_exists(
    PostgreSQL::PostgreSQL
    pg_encoding_to_char
    ""
    HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT
  )

  check_library_exists(
    PostgreSQL::PostgreSQL
    lo_truncate64
    ""
    HAVE_PG_LO64
  )

  check_library_exists(
    PostgreSQL::PostgreSQL
    PQsetErrorContextVisibility
    ""
    HAVE_PG_CONTEXT_VISIBILITY
  )
endif()

set(HAVE_PGSQL TRUE)

configure_file(cmake/config.h.in config.h)
