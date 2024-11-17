#[=============================================================================[
Find the ICU library.

See: https://cmake.org/cmake/help/latest/module/FindICU.html

This module overrides the upstream CMake `FindICU` module with few
customizations:

* Added pkg-config.
* Marked `ICU_INCLUDE_DIR` as advanced variable (fixed upstream in CMake 3.29).
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  ICU
  PROPERTIES
    URL "https://icu.unicode.org/"
    DESCRIPTION "International Components for Unicode"
)

# Try pkg-config and append paths to the internal icu_roots variable.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  foreach(component ${ICU_FIND_COMPONENTS})
    string(TOUPPER ${component} component_upper)
    pkg_check_modules(PC_ICU_${component_upper} QUIET icu-${component})

    list(APPEND icu_roots ${PC_ICU_${component_upper}_INCLUDE_DIRS})
    list(APPEND icu_roots ${PC_ICU_${component_upper}_LIBRARY_DIRS})
  endforeach()

  if(icu_roots)
    list(REMOVE_DUPLICATES icu_roots)
  endif()
endif()

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindICU)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)

# Upstream CMake module doesn't mark these as advanced variables.
# https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9199
if(CMAKE_VERSION VERSION_LESS 3.29)
  mark_as_advanced(ICU_INCLUDE_DIR)
endif()
