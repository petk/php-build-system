#[=============================================================================[
# FindBZip2

This module overrides the upstream CMake `FindBZip2` module with few
customizations:

* Added BZip2_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindBZip2.html
#]=============================================================================]

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindBZip2.cmake)

if(CMAKE_VERSION VERSION_LESS 4.2)
  set(BZip2_VERSION "${BZIP2_VERSION}")
endif()
