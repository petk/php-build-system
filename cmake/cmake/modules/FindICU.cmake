#[=============================================================================[
# FindICU

This module overrides the upstream CMake `FindICU` module with few
customizations:

* Added pkg-config.

See: https://cmake.org/cmake/help/latest/module/FindICU.html
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

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindICU.cmake)
