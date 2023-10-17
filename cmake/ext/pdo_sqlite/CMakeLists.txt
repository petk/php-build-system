include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_PDO_SQLITE "Whether to enable the pdo_sqlite extension" ON)

cmake_dependent_option(
  EXT_PDO_SQLITE_SHARED
  "Whether to build the pdo_sqlite extension as shared object"
  OFF
  "EXT_PDO_SQLITE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_SQLITE)
  return()
endif()

if(NOT EXT_PDO_SQLITE_SHARED AND EXT_PDO_SHARED)
  set(EXT_PDO_SQLITE_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_SQLITE_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_pdo_sqlite ${_library_type}
  pdo_sqlite.c
  sqlite_driver.c
  sqlite_statement.c
)

set_target_properties(php_pdo_sqlite PROPERTIES PHP_EXT_DEPENDS php_pdo)

find_package(SQLite3 3.7.7 REQUIRED)

target_link_libraries(php_pdo_sqlite PRIVATE SQLite::SQLite3)

set(HAVE_PDO_SQLITELIB 1 CACHE INTERNAL "Define to 1 if you have the pdo_sqlite extension enabled.")

check_library_exists(SQLite::SQLite3 sqlite3_close_v2 "" HAVE_SQLITE3_CLOSE_V2)
check_library_exists(SQLite::SQLite3 sqlite3_column_table_name "" HAVE_SQLITE3_COLUMN_TABLE_NAME)

target_include_directories(php_pdo_sqlite PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")
