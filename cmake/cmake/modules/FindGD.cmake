#[=============================================================================[
CMake module to find and use GD library.

If libgd is found, the following variables are set:

GD_FOUND
  Set to 1 if libgd is found.
GD_LIBRARIES
  A list of libraries for using libgd.
GD_INCLUDE_DIRS
  A list of include directories for using libgd.
GD_VERSION
  Version string of found libgd.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(GD_FIND_VERSION)
    set(_pkg_module_spec "gdlib>=${GD_FIND_VERSION}")
  else()
    set(_pkg_module_spec "gdlib")
  endif()

  pkg_search_module(GD QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  GD
  REQUIRED_VARS GD_LIBRARIES
  VERSION_VAR GD_VERSION
  REASON_FAILURE_MESSAGE "GD not found. Please install libgd."
)
