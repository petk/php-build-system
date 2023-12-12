#[=============================================================================[
Find the FFI library.

Module defines the following IMPORTED targets:

  FFI::FFI
    The FFI library, if found.

Result variables:

  FFI_FOUND
    Whether FFI library is found.
  FFI_INCLUDE_DIRS
    A list of include directories for using FFI library.
  FFI_LIBRARIES
    A list of libraries to link when using FFI library.
  FFI_VERSION
    Version string of found FFI library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(FFI PROPERTIES
  URL "https://sourceware.org/libffi/"
  DESCRIPTION "Foreign Function Interfaces library"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(FFI_FIND_VERSION)
    set(_pkg_module_spec "libffi>=${FFI_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libffi")
  endif()

  pkg_search_module(FFI QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  FFI
  REQUIRED_VARS FFI_LIBRARIES
  VERSION_VAR FFI_VERSION
  REASON_FAILURE_MESSAGE "FFI not found. Please install FFI library (libffi)."
)

if(FFI_FOUND AND NOT TARGET FFI::FFI)
  add_library(FFI::FFI INTERFACE IMPORTED)

  set_target_properties(FFI::FFI PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FFI_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${FFI_LIBRARIES}"
  )
endif()
