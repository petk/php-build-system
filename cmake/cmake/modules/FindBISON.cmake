#[=============================================================================[
# FindBISON

Find `bison`, the general-purpose parser generator, command-line executable.

This module extends the upstream CMake `FindBISON` module.
See: https://cmake.org/cmake/help/latest/module/FindBISON.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  BISON
  PROPERTIES
    URL "https://www.gnu.org/software/bison/"
    DESCRIPTION "General-purpose parser generator"
)

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindBISON)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)
