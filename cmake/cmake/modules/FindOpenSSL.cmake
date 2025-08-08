#[=============================================================================[
# FindOpenSSL

This module overrides the upstream CMake `FindOpenSSL` module with few
customizations:

* Added OpenSSL_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindOpenSSL.html
#]=============================================================================]

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindOpenSSL.cmake)

if(CMAKE_VERSION VERSION_LESS 4.2)
  set(OpenSSL_VERSION "${OPENSSL_VERSION}")
endif()
