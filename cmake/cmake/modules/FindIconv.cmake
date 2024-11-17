#[=============================================================================[
Find the Iconv library.

See: https://cmake.org/cmake/help/latest/module/FindIconv.html

Module overrides the upstream CMake `FindIconv` module with few customizations.

Includes a customization for Alpine where GNU libiconv headers are located in
`/usr/include/gnu-libiconv` (fixed in CMake 3.31):
https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9774
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  Iconv
  PROPERTIES
    DESCRIPTION "Internationalization conversion library"
)

# Adjustment when overriding the iconv library path, otherwise Iconv is first
# searched in C library.
if(CMAKE_PREFIX_PATH OR Iconv_ROOT)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.31)
    set(Iconv_IS_BUILT_IN FALSE)
  else()
    find_path(
      php_iconv_INCLUDE_DIR
      NAMES iconv.h
      PATHS
        ${CMAKE_PREFIX_PATH}
        ${Iconv_ROOT}
      PATH_SUFFIXES
        # GNU libiconv on Alpine Linux has header located on a special location:
        include/gnu-libiconv
        # For other paths try with the standard suffix:
        include
      NO_DEFAULT_PATH
    )

    if(php_iconv_INCLUDE_DIR)
      set(Iconv_INCLUDE_DIR ${php_iconv_INCLUDE_DIR})
      # Disable built-in iconv when overriding search paths in CMake's FindIconv.
      set(Iconv_IS_BUILT_IN FALSE)
    endif()
  endif()
endif()

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindIconv)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)
