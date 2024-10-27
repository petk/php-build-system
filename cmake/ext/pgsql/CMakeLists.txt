project(
  PhpExtensionPgSql
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PGSQL "Enable the pgsql extension" OFF)

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
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
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
  check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _PHP_LIBPQ_CHECK)
  if(NOT _PHP_LIBPQ_CHECK)
    message(
      FATAL_ERROR
      "PostgreSQL check failed: libpq ${PHP_POSTGRESQL_MIN_VERSION} or later "
      "is required, please see CMake logs for details."
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

set(HAVE_PGSQL 1)

configure_file(config.cmake.h.in config.h @ONLY)
