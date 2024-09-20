#[=============================================================================[
Find the XSLT library (LibXslt).

See: https://cmake.org/cmake/help/latest/module/FindLibXslt.html

Module overrides the upstream CMake `FindLibXslt` module with few
customizations:

* Marked `LIBXSLT_EXSLT_INCLUDE_DIR` and `LIBXSLT_LIBRARY` as advanced variables
  (fixed upstream in CMake 3.28).

Hints:

The `LibXslt_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  LibXslt
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxslt"
    DESCRIPTION "XSLT processor library"
)

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindLibXslt)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)

# Upstream CMake module doesn't mark these as advanced variables.
# https://gitlab.kitware.com/cmake/cmake/-/merge_requests/8807
if(CMAKE_VERSION VERSION_LESS 3.28)
  mark_as_advanced(LIBXSLT_EXSLT_INCLUDE_DIR LIBXSLT_LIBRARY)
endif()
