include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_PGSQL "Whether to enable the pdo_pgsql extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_PGSQL_SHARED "Whether to build the pdo_pgsql extension as shared object" OFF "EXT_PDO_PGSQL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_PGSQL)
  return()
endif()

if(EXT_PDO_PGSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "pdo_pgsql" ${_library_type})

add_library(ext_pdo_pgsql ${_library_type}
  pdo_pgsql.c
  pgsql_driver.c
  pgsql_statement.c
)

target_include_directories(ext_pdo_pgsql PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")

# TODO: Autoconf still allows 9.1 to be installed. This one relies on pkg-config
# and minimum PostgreSQL 9.3.
find_package(PostgreSQL 9.1 REQUIRED)

if(PostgreSQL_LIBRARIES)
  target_link_libraries(ext_pdo_pgsql PRIVATE ${PostgreSQL_LIBRARIES})
endif()

if(PostgreSQL_INCLUDE_DIRS)
  target_include_directories(
    ext_pdo_pgsql
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
