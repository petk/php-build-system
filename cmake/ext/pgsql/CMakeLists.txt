include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PGSQL "Enable the pgsql extension" OFF)

add_feature_info("ext/pgsql" EXT_PGSQL
  "Adds support for PostgreSQL database."
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

target_sources(php_pgsql PRIVATE
  pgsql.c
)

target_compile_definitions(php_pgsql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(PostgreSQL 9.1)
set_package_properties(PostgreSQL PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the pgsql extension."
)

target_link_libraries(php_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Sanity check.
check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _have_pqlibversion)

if(NOT _have_pqlibversion)
  message(FATAL_ERROR "PQlibVersion could not be found. Something is wrong with the libpq library. See the logs.")
endif()

check_library_exists(PostgreSQL::PostgreSQL pg_encoding_to_char "" HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT)
check_library_exists(PostgreSQL::PostgreSQL lo_truncate64 "" HAVE_PG_LO64)
check_library_exists(PostgreSQL::PostgreSQL PQsetErrorContextVisibility "" HAVE_PG_CONTEXT_VISIBILITY)
