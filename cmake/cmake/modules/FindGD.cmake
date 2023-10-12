#[=============================================================================[
Find the GD library.
https://libgd.github.io/

Module defines the following IMPORTED targets:

  GD::GD
    The GD library, if found.

Result variables:

  GD_FOUND
    Set to 1 if libgd is found.
  GD_INCLUDE_DIRS
    A list of include directories for using libgd.
  GD_LIBRARIES
    A list of libraries for using libgd.
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
  REASON_FAILURE_MESSAGE "GD not found. Please install GD library (libgd)."
)

if(GD_FOUND AND NOT TARGET GD::GD)
  add_library(GD::GD INTERFACE IMPORTED)

  set_target_properties(GD::GD PROPERTIES
    INTERFACE_LINK_LIBRARIES "${GD_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${GD_INCLUDE_DIRS}"
  )
endif()
