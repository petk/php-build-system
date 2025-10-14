#[=============================================================================[
# FindIntl

This module overrides the upstream CMake `FindIntl` module with few
customizations:

* Enabled finding Intl library with `CMAKE_PREFIX_PATH`, `Intl_ROOT`, or
  `INTL_ROOT` hint variable.

See: https://cmake.org/cmake/help/latest/module/FindIntl.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  Intl
  PROPERTIES
    DESCRIPTION "The Gettext libintl"
)

# Disable searching for built-in intl when overriding search paths.
if(
  NOT DEFINED Intl_IS_BUILT_IN
  AND NOT DEFINED Intl_INCLUDE_DIR
  AND NOT DEFINED Intl_LIBRARY
  AND (
    CMAKE_PREFIX_PATH
    OR Intl_ROOT
    OR INTL_ROOT
    OR DEFINED ENV{Intl_ROOT}
    OR DEFINED ENV{INTL_ROOT}
  )
)
  find_path(
    Intl_INCLUDE_DIR
    NAMES libintl.h
    DOC "libintl include directory"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  find_library(
    Intl_LIBRARY
    NAMES intl libintl
    NAMES_PER_DIR
    DOC "libintl libraries (if not in the C library)"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  if(Intl_INCLUDE_DIR AND Intl_LIBRARY)
    set(Intl_IS_BUILT_IN FALSE)
  else()
    unset(Intl_INCLUDE_DIR CACHE)
    unset(Intl_LIBRARY CACHE)
  endif()
endif()

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindIntl.cmake)
