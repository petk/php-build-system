#[=============================================================================[
# FindLibXslt

Find the XSLT library (LibXslt).

See: https://cmake.org/cmake/help/latest/module/FindLibXslt.html

Module overrides the upstream CMake `FindLibXslt` module with few
customizations:

* Marked `LIBXSLT_EXSLT_INCLUDE_DIR` and `LIBXSLT_LIBRARY` as advanced variables
  (fixed upstream in CMake 3.28).
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
