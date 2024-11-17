#[=============================================================================[
Find the Intl library.

Module overrides the upstream CMake `FindIntl` module with few customizations.

Enables finding Intl library with `Intl_ROOT` hint variable.

See: https://cmake.org/cmake/help/latest/module/FindIntl.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  Intl
  PROPERTIES
    DESCRIPTION "The Gettext libintl"
)

# Disable built-in intl when overriding search paths in CMake's FindIntl.
if(CMAKE_PREFIX_PATH OR Intl_ROOT)
  find_path(
    php_intl_INCLUDE_DIR
    NAMES libintl.h
    PATHS
      ${CMAKE_PREFIX_PATH}
      ${Intl_ROOT}
    PATH_SUFFIXES
      include
    NO_DEFAULT_PATH
  )

  if(php_intl_INCLUDE_DIR)
    set(Intl_INCLUDE_DIR ${php_intl_INCLUDE_DIR})
    set(Intl_IS_BUILT_IN FALSE)
  endif()
endif()

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindIntl)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)
