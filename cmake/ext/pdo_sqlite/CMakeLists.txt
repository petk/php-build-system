include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_SQLITE
  "Enable the pdo_sqlite extension"
  ON
  "EXT_PDO"
  OFF
)

add_feature_info(
  "ext/pdo_sqlite"
  EXT_PDO_SQLITE
  "SQLite 3 database support in PDO (PHP Data Objects) interface"
)

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
  add_library(php_pdo_sqlite SHARED)
else()
  add_library(php_pdo_sqlite)
endif()

target_sources(
  php_pdo_sqlite
  PRIVATE
    pdo_sqlite.c
    sqlite_driver.c
    sqlite_statement.c
)

add_dependencies(php_pdo_sqlite php_pdo)

target_include_directories(
  php_pdo_sqlite
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

find_package(SQLite3 3.7.7)
set_package_properties(
  SQLite3
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_sqlite extension."
)

target_link_libraries(php_pdo_sqlite PRIVATE SQLite::SQLite3)

if(TARGET SQLite::SQLite3)
  set(
    HAVE_PDO_SQLITELIB 1
    CACHE INTERNAL "Define to 1 if you have the pdo_sqlite extension enabled."
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_close_v2
    ""
    HAVE_SQLITE3_CLOSE_V2
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_column_table_name
    ""
    HAVE_SQLITE3_COLUMN_TABLE_NAME
  )

  check_library_exists(
    SQLite::SQLite3
    sqlite3_load_extension
    ""
    HAVE_SQLITE3_LOAD_EXTENSION
  )

  if(NOT HAVE_SQLITE3_LOAD_EXTENSION)
    set(
      PDO_SQLITE_OMIT_LOAD_EXTENSION 1
      CACHE INTERNAL "Sqlite3 without extension support"
    )
  endif()
endif()
