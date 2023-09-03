#[=============================================================================[
CMake module to find and use the FFI library.
https://sourceware.org/libffi/

If the FFI library is found, the following variables are set:

FFI_FOUND
  Set to 1 if FFI library is found.
FFI_LIBRARIES
  A list of libraries to link when using FFI library.
FFI_INCLUDE_DIRS
  A list of include directories for using FFI library.
FFI_VERSION
  Version string of found FFI library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

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
  REASON_FAILURE_MESSAGE "FFI not found. Please install FFI library."
)
