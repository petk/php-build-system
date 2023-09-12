include(CheckLibraryExists)
include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_SQLITE "Whether to enable the pdo_sqlite extension" ON "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_SQLITE_SHARED "Whether to build the pdo_sqlite extension as shared object" OFF "EXT_PDO_SQLITE;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_SQLITE)
  return()
endif()

if(EXT_PDO_SQLITE_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "pdo_sqlite" ${_library_type})

add_library(ext_pdo_sqlite ${_library_type}
  pdo_sqlite.c
  sqlite_driver.c
  sqlite_statement.c
)

find_package(SQLite3 3.7.7 REQUIRED)

if(SQLite3_LIBRARIES)
  target_link_libraries(ext_pdo_sqlite PRIVATE ${SQLite3_LIBRARIES})
endif()

if(SQLite3_INCLUDE_DIRS)
  target_include_directories(ext_pdo_sqlite PRIVATE ${SQLite3_INCLUDE_DIRS})
endif()

set(HAVE_PDO_SQLITELIB 1 CACHE INTERNAL "Define to 1 if you have the pdo_sqlite extension enabled.")

check_library_exists(${SQLite3_LIBRARIES} sqlite3_close_v2 "" HAVE_SQLITE3_CLOSE_V2)
check_library_exists(${SQLite3_LIBRARIES} sqlite3_column_table_name "" HAVE_SQLITE3_COLUMN_TABLE_NAME)

# TODO: Check if this can be done better.
target_include_directories(ext_pdo_sqlite PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../")
