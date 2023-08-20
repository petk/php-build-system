include(CheckLibraryExists)
include(CMakeDependentOption)

cmake_dependent_option(pdo_sqlite "Whether to enable the pdo_sqlite extension" ON "pdo" OFF)

if(NOT pdo_sqlite)
  return()
endif()

string(TOLOWER ${pdo_sqlite} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "pdo_sqlite" ${extension_library_type})

add_library(ext_pdo_sqlite ${extension_library_type}
  pdo_sqlite.c
  sqlite_driver.c
  sqlite_statement.c
)

find_package(SQLite3 3.7.7 REQUIRED)

target_link_libraries(ext_pdo_sqlite PRIVATE ${SQLite3_LIBRARIES})

if(${SQLite3_INCLUDE_DIRS})
  target_include_directories(ext_pdo_sqlite PRIVATE ${SQLite3_INCLUDE_DIRS})
endif()

set(HAVE_PDO_SQLITELIB 1 CACHE STRING "Define to 1 if you have the pdo_sqlite extension enabled.")

check_library_exists(sqlite3 sqlite3_close_v2 "" HAVE_SQLITE3_CLOSE_V2)
check_library_exists(sqlite3 sqlite3_column_table_name "" HAVE_SQLITE3_COLUMN_TABLE_NAME)

# TODO: Check if this can be done better.
target_include_directories(ext_pdo_sqlite PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../")
