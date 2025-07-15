#[=============================================================================[
# FindLibXslt

This module overrides the upstream CMake `FindLibXslt` module.

See: https://cmake.org/cmake/help/latest/module/FindLibXslt.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  LibXslt
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxslt"
    DESCRIPTION "XSLT processor library"
)

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindLibXslt.cmake)
