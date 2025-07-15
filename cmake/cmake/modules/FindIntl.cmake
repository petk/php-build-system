#[=============================================================================[
# FindIntl

This module overrides the upstream CMake `FindIntl` module with few
customizations:

* Enabled finding Intl library with `INTL_ROOT` hint variable.

See: https://cmake.org/cmake/help/latest/module/FindIntl.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  Intl
  PROPERTIES
    DESCRIPTION "The Gettext libintl"
)

# Disable built-in intl when overriding search paths in CMake's FindIntl.
if(CMAKE_PREFIX_PATH OR Intl_ROOT OR INTL_ROOT)
  find_path(
    php_intl_INCLUDE_DIR
    NAMES libintl.h
    PATHS
      ${CMAKE_PREFIX_PATH}
      ${Intl_ROOT}
      ${INTL_ROOT}
    PATH_SUFFIXES
      include
    NO_DEFAULT_PATH
  )

  if(php_intl_INCLUDE_DIR)
    set(Intl_INCLUDE_DIR ${php_intl_INCLUDE_DIR})
    set(Intl_IS_BUILT_IN FALSE)
  endif()
endif()

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindIntl.cmake)
