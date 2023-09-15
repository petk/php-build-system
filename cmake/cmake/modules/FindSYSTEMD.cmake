#[=============================================================================[
Find the systemd library (libsystemd).

If systemd library is found, the following variables are set:

SYSTEMD_FOUND
  Set to 1 if systemd library is found.
SYSTEMD_LIBRARIES
  A list of libraries for using systemd library.
SYSTEMD_INCLUDE_DIRS
  A list of include directories for using systemd library.
SYSTEMD_VERSION
  Version string of found systemd library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(SYSTEMD_FIND_VERSION)
    set(_pkg_module_spec "libsystemd>=${SYSTEMD_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libsystemd")
  endif()

  pkg_search_module(SYSTEMD QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  SYSTEMD
  REQUIRED_VARS SYSTEMD_LIBRARIES
  VERSION_VAR SYSTEMD_VERSION
  REASON_FAILURE_MESSAGE "The systemd not found. Please install systemd library."
)
