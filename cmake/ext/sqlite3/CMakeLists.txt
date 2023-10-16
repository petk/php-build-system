include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_SQLITE3 "Whether to enable the sqlite3 extension" ON)

cmake_dependent_option(
  EXT_SQLITE3_SHARED
  "Whether to build the sqlite3 extension as shared object"
  OFF
  "EXT_SQLITE3;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SQLITE3)
  return()
endif()

if(EXT_SQLITE3_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "sqlite3" ${_library_type})

add_library(php_sqlite3 ${_library_type}
  sqlite3.c
)

target_compile_definitions(php_sqlite3 PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(SQLite3 3.7.7 REQUIRED)

target_link_libraries(php_sqlite3 PRIVATE SQLite::SQLite3)

check_library_exists(SQLite::SQLite3 sqlite3_errstr "" HAVE_SQLITE3_ERRSTR)
check_library_exists(SQLite::SQLite3 sqlite3_expanded_sql "" HAVE_SQLITE3_EXPANDED_SQL)
check_library_exists(SQLite::SQLite3 sqlite3_load_extension "" HAVE_SQLITE3_LOAD_EXTENSION)

if(NOT HAVE_SQLITE3_LOAD_EXTENSION)
  set(SQLITE_OMIT_LOAD_EXTENSION 1 CACHE STRING "Have sqlite3 with extension support")
endif()
