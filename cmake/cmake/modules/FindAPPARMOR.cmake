#[=============================================================================[
Find the AppArmor library.
https://apparmor.net/

If AppArmor library is found, the following variables are set:

APPARMOR_FOUND
  Set to 1 if AppArmor library is found.
APPARMOR_INCLUDE_DIRS
  A list of include directories for using AppArmor library.
APPARMOR_LIBRARIES
  A list of libraries for using AppArmor library.
APPARMOR_VERSION
  Version string of found AppArmor library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(APPARMOR_FIND_VERSION)
    set(_pkg_module_spec "libapparmor>=${APPARMOR_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libapparmor")
  endif()

  pkg_search_module(APPARMOR QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  APPARMOR
  REQUIRED_VARS APPARMOR_LIBRARIES
  VERSION_VAR APPARMOR_VERSION
  REASON_FAILURE_MESSAGE "AppArmor not found. Please install AppArmor library."
)
