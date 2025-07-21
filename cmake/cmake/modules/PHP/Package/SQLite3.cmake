#[=============================================================================[
# PHP/Package/SQLite3

Finds or downloads the SQLite library:

```cmake
include(PHP/Package/SQLite3)
```

This module is a wrapper for finding the SQLite library. It first tries to
find the SQLite library on the system. If not successful it tries to download
it from the upstream source and builds it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindSQLite3.html

## Examples

Basic usage:

```cmake
include(PHP/Package/SQLite3)
php_package_sqlite3()
target_link_libraries(php_ext_foo PRIVATE SQLite::SQLite3)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)
include(PHP/Package/_Internal)

set_package_properties(
  SQLite3
  PROPERTIES
    URL "https://www.sqlite.org/"
    DESCRIPTION "SQL database engine library"
)

# Minimum required version for the SQLite dependency.
set(PHP_SQLITE3_MIN_VERSION 3.7.7)

# Download version when system dependency is not found.
set(PHP_SQLITE3_DOWNLOAD_VERSION 3.50.2)

set(PHP_SQLITE3_URL)

macro(php_package_sqlite3)
  FetchContent_Declare(
    SQLite3
    URL ${PHP_SQLITE3_URL}
    SOURCE_SUBDIR non-existing
    FIND_PACKAGE_ARGS ${PHP_SQLITE3_MIN_VERSION}
  )

  find_package(SQLite3 ${PHP_SQLITE3_MIN_VERSION})

  if(PHP_USE_FETCHCONTENT)
    if(NOT SQLite3_FOUND)
      message(STATUS "Downloading ${PHP_SQLITE3_URL}")
    endif()

    FetchContent_MakeAvailable(SQLite3)

    if(NOT SQLite3_FOUND)
      _php_package_sqlite3_init()
    endif()
  endif()

  get_property(PHP_SQLITE3_DOWNLOADED GLOBAL PROPERTY _PHP_SQLITE3_DOWNLOADED)

  if(PHP_SQLITE3_DOWNLOADED)
    set(SQLite3_VERSION ${PHP_SQLite3_DOWNLOAD_VERSION})
  endif()
endmacro()

macro(_php_package_sqlite3_init)
  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  ExternalProject_Add(
    SQLite3
    STEP_TARGETS build install
    SOURCE_DIR ${sqlite3_SOURCE_DIR}
    BINARY_DIR ${sqlite3_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/sqlite3-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libsqlite3${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  ExternalProject_Get_Property(SQLite3 INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(SQLite::SQLite3 STATIC IMPORTED GLOBAL)
  add_dependencies(SQLite::SQLite3 SQLite3-install)
  set_target_properties(
    SQLite::SQLite3
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libsqlite3${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  php_package_mark_as_found(SQLite3)

  define_property(
    GLOBAL
    PROPERTY _PHP_SQLITE3_DOWNLOADED
    BRIEF_DOCS "Marker that SQLite3 library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_SQLITE3_DOWNLOADED TRUE)
endmacro()

php_package_sqlite3()
