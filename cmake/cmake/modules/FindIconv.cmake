#[=============================================================================[
# FindIconv

This module overrides the upstream CMake `FindIconv` module with few
customizations.

* Added adjustment when the iconv library installation path is manually set,
  otherwise Iconv is first searched in the C library.

See: https://cmake.org/cmake/help/latest/module/FindIconv.html
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  Iconv
  PROPERTIES
    DESCRIPTION "Internationalization conversion library"
)

# Disable searching for built-in iconv when overriding search paths.
if(
  NOT DEFINED Iconv_IS_BUILT_IN
  AND NOT DEFINED Iconv_INCLUDE_DIR
  AND NOT DEFINED Iconv_LIBRARY
  AND (
    CMAKE_PREFIX_PATH
    OR Iconv_ROOT
    OR ICONV_ROOT
    OR DEFINED ENV{Iconv_ROOT}
    OR DEFINED ENV{ICONV_ROOT}
  )
)
  find_path(
    Iconv_INCLUDE_DIR
    NAMES iconv.h
    PATH_SUFFIXES
      gnu-libiconv # GNU libiconv on Alpine Linux has header in a subdirectory.
    DOC "iconv include directory"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  find_library(
    Iconv_LIBRARY
    NAMES iconv libiconv
    NAMES_PER_DIR
    DOC "iconv library (if not in the C library)"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  if(Iconv_INCLUDE_DIR AND Iconv_LIBRARY)
    set(Iconv_IS_BUILT_IN FALSE)
  else()
    unset(CACHE{Iconv_INCLUDE_DIR})
    unset(CACHE{Iconv_LIBRARY})
  endif()
endif()

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindIconv.cmake)
