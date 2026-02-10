#[=============================================================================[
# FindSQLite3

This module overrides the upstream CMake `FindSQLite3` module with few
customizations:

* Added imported target `SQLite3::SQLite3` available as of CMake 4.3.

See: https://cmake.org/cmake/help/latest/module/FindSQLite3.html
#]=============================================================================]

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindSQLite3.cmake)

if(
  CMAKE_VERSION VERSION_LESS 4.3
  AND NOT TARGET SQLite3::SQLite3
  AND TARGET SQLite::SQLite3
)
  add_library(SQLite3::SQLite3 ALIAS SQLite::SQLite3)
endif()
