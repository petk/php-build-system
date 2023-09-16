#[=============================================================================[
CMake module to find and use Editline library.
https://thrysoee.dk/editline/

If Editline library is found, the following variables are set:

EDIT_FOUND
  Set to 1 if Editline library is found.
EDIT_INCLUDE_DIRS
  A list of include directories for using Editline library.
EDIT_LIBRARIES
  A list of libraries for using Editline library.
EDIT_VERSION
  Version string of found Editline library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(EDIT_FIND_VERSION)
    set(_pkg_module_spec "libedit>=${EDIT_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libedit")
  endif()

  pkg_search_module(EDIT QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  EDIT
  REQUIRED_VARS EDIT_LIBRARIES
  VERSION_VAR EDIT_VERSION
  REASON_FAILURE_MESSAGE "Editline not found. Please install Editline library (libedit)."
)
