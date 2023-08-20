include(CheckLibraryExists)

option(sqlite3 "Whether to enable the sqlite3 extension" ON)

if(NOT sqlite3)
  return()
endif()

string(TOLOWER ${sqlite3} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "sqlite3" ${extension_library_type})

add_library(ext_sqlite3 ${extension_library_type}
  sqlite3.c
)

target_compile_definitions(ext_sqlite3 PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(SQLite3 3.7.7 REQUIRED)

target_link_libraries(ext_sqlite3 PRIVATE ${SQLite3_LIBRARIES})

if(${SQLite3_INCLUDE_DIRS})
  target_include_directories(ext_sqlite3 PRIVATE ${SQLite3_INCLUDE_DIRS})
endif()

check_library_exists(sqlite3 sqlite3_errstr "" HAVE_SQLITE3_ERRSTR)
check_library_exists(sqlite3 sqlite3_expanded_sql "" HAVE_SQLITE3_EXPANDED_SQL)
check_library_exists(sqlite3 sqlite3_load_extension "" HAVE_SQLITE3_LOAD_EXTENSION)

if(NOT HAVE_SQLITE3_LOAD_EXTENSION)
  set(SQLITE_OMIT_LOAD_EXTENSION 1 CACHE STRING "Have sqlite3 with extension support")
endif()
