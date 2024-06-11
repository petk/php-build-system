include(CheckLibraryExists)
include(CheckSourceCompiles)
include(CMakeDependentOption)
include(CMakePushCheckState)
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
)

target_compile_definitions(php_pgsql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

add_dependencies(php_pgsql php_pcre)

find_package(PostgreSQL ${PHP_POSTGRESQL_MIN_VERSION})
set_package_properties(
  PostgreSQL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pgsql extension."
)

target_link_libraries(php_pgsql PUBLIC PostgreSQL::PostgreSQL)

# Sanity check.
if(TARGET PostgreSQL::PostgreSQL)
  check_library_exists(PostgreSQL::PostgreSQL PQlibVersion "" HAVE_PQLIBVERSION)

  if(NOT HAVE_PQLIBVERSION)
    message(
      FATAL_ERROR
      "PQlibVersion could not be found. Something is wrong with the libpq "
      "library. See the logs."
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
  endif()
endif()
