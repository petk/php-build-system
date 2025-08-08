#[=============================================================================[
# FindPostgreSQL

This module overrides the upstream CMake `FindPostgreSQL` module with few
customizations:

* Added PostgreSQL_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindPostgreSQL.html
#]=============================================================================]

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindPostgreSQL.cmake)

if(CMAKE_VERSION VERSION_LESS 4.2)
  set(PostgreSQL_VERSION "${PostgreSQL_VERSION_STRING}")
endif()
