#[=============================================================================[
Find the Capstone library.
https://www.capstone-engine.org

If Capstone library is found, the following variables are set:

CAPSTONE_FOUND
  Set to 1 if Capstone library is found.
CAPSTONE_INCLUDE_DIRS
  A list of include directories for using Capstone library.
CAPSTONE_LIBRARIES
  A list of libraries for using Capstone library.
CAPSTONE_VERSION
  Version string of found Capstone library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(CAPSTONE_FIND_VERSION)
    set(_pkg_module_spec "capstone>=${CAPSTONE_FIND_VERSION}")
  else()
    set(_pkg_module_spec "capstone")
  endif()

  pkg_search_module(CAPSTONE QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  CAPSTONE
  REQUIRED_VARS CAPSTONE_LIBRARIES
  VERSION_VAR CAPSTONE_VERSION
  REASON_FAILURE_MESSAGE "Capstone not found. Please install Capstone library."
)
