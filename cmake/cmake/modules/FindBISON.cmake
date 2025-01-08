#[=============================================================================[
# FindBISON

Find `bison`, the general-purpose parser generator, command-line executable.

This module extends the CMake `FindBISON` module.
See: https://cmake.org/cmake/help/latest/module/FindBISON.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  BISON
  PROPERTIES
    URL "https://www.gnu.org/software/bison/"
    DESCRIPTION "General-purpose parser generator"
)

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindBISON.cmake)
