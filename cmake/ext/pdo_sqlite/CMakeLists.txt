include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_PDO_SQLITE "Enable the pdo_sqlite extension" ON)

cmake_dependent_option(
  EXT_PDO_SQLITE_SHARED
  "Build the pdo_sqlite extension as a shared library"
  OFF
  "EXT_PDO_SQLITE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_SQLITE)
  return()
endif()

if(EXT_PDO_SQLITE_SHARED)
  set(_type "SHARED")
endif()

add_library(php_pdo_sqlite ${_type}
  pdo_sqlite.c
  sqlite_driver.c
  sqlite_statement.c
)

set_target_properties(php_pdo_sqlite PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo)

find_package(SQLite3 3.7.7 REQUIRED)

target_link_libraries(php_pdo_sqlite PRIVATE SQLite::SQLite3)

set(HAVE_PDO_SQLITELIB 1 CACHE INTERNAL "Define to 1 if you have the pdo_sqlite extension enabled.")

check_library_exists(SQLite::SQLite3 sqlite3_close_v2 "" HAVE_SQLITE3_CLOSE_V2)
check_library_exists(SQLite::SQLite3 sqlite3_column_table_name "" HAVE_SQLITE3_COLUMN_TABLE_NAME)

target_include_directories(php_pdo_sqlite PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")
