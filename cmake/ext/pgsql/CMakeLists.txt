include(CMakeDependentOption)

option(EXT_PGSQL "Whether to enable the pgsql extension" OFF)

cmake_dependent_option(EXT_PGSQL_SHARED "Whether to build the pgsql extension as shared object" OFF "EXT_PGSQL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PGSQL)
  return()
endif()

if(EXT_PGSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "pgsql" ${_library_type})

add_library(php_pgsql ${_library_type}
  pgsql.c
)

target_compile_definitions(php_pgsql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(PostgreSQL 9.1 REQUIRED)

target_link_libraries(php_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Sanity check.
check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" _have_pqlibversion)

if(NOT _have_pqlibversion)
  message(FATAL_ERROR "PQlibVersion could not be found. Something is wrong with the libpq library. See the logs.")
endif()

check_library_exists(PostgreSQL::PostgreSQL pg_encoding_to_char "" HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT)
check_library_exists(PostgreSQL::PostgreSQL lo_truncate64 "" HAVE_PG_LO64)
check_library_exists(PostgreSQL::PostgreSQL PQsetErrorContextVisibility "" HAVE_PG_CONTEXT_VISIBILITY)
