#[=============================================================================[
CMake module to find and use XPM library.

If xpm library is found, the following variables are set:

XPM_FOUND
  Set to 1 if xpm library is found.
XPM_LIBRARIES
  A list of libraries for using xpm.
XPM_INCLUDE_DIRS
  A list of include directories for using xpm library.
XPM_VERSION
  Version string of found xpm.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(XPM_FIND_VERSION)
    set(_pkg_module_spec "xpm>=${XPM_FIND_VERSION}")
  else()
    set(_pkg_module_spec "xpm")
  endif()

  pkg_search_module(XPM QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  XPM
  REQUIRED_VARS XPM_LIBRARIES
  VERSION_VAR XPM_VERSION
  REASON_FAILURE_MESSAGE "XPM not found. Please install xpm library."
)
