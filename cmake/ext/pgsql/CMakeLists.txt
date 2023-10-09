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

add_library(pgsql ${_library_type}
  pgsql.c
)

target_compile_definitions(pgsql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# TODO: Autoconf still allows 9.1 to be installed. This one relies on pkg-config
# and minimum PostgreSQL 9.3.
find_package(PostgreSQL 9.1 REQUIRED)

if(PostgreSQL_LIBRARIES)
  target_link_libraries(pgsql PRIVATE ${PostgreSQL_LIBRARIES})
endif()

if(PostgreSQL_INCLUDE_DIRS)
  target_include_directories(
    pgsql
    PRIVATE ${PostgreSQL_INCLUDE_DIRS}
    INTERFACE ${PostgreSQL_INCLUDE_DIRS}
  )
endif()

# Sanity check.
check_library_exists(${PostgreSQL_LIBRARIES} PQlibVersion "" _sanity_check)

if(NOT _sanity_check)
  message(FATAL_ERROR "PQlibVersion could not be found. Something is wrong with the libpq library. See the logs.")
endif()

unset(_sanity_check CACHE)

check_library_exists(${PostgreSQL_LIBRARIES} pg_encoding_to_char "" HAVE_PGSQL_WITH_MULTIBYTE_SUPPORT)
check_library_exists(${PostgreSQL_LIBRARIES} lo_truncate64 "" HAVE_PG_LO64)
check_library_exists(${PostgreSQL_LIBRARIES} PQsetErrorContextVisibility "" HAVE_PG_CONTEXT_VISIBILITY)
