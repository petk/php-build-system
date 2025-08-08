#[=============================================================================[
# FindLibXml2

This module overrides the upstream CMake `FindLibXml2` module with few
customizations:

* Added LibXml2_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html
#]=============================================================================]

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindLibXml2.cmake)

if(CMAKE_VERSION VERSION_LESS 4.2)
  set(LibXml2_VERSION "${LIBXML2_VERSION_STRING}")
endif()
