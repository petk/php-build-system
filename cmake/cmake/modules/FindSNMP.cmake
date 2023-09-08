#[=============================================================================[
CMake module to find and use the NET SNMP library.
http://www.net-snmp.org/

If NET SNMP library is found, the following variables are set:

SNMP_FOUND
  Set to 1 if NET SNMP library is found.
SNMP_LIBRARIES
  A list of libraries for using NET SNMP library.
SNMP_INCLUDE_DIRS
  A list of include directories for using NET SNMP library.
SNMP_VERSION
  Version string of found NET SNMP library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(SNMP_FIND_VERSION)
    set(_pkg_module_spec "netsnmp>=${SNMP_FIND_VERSION}")
  else()
    set(_pkg_module_spec "netsnmp")
  endif()

  pkg_search_module(SNMP QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  SNMP
  REQUIRED_VARS SNMP_LIBRARIES
  VERSION_VAR SNMP_VERSION
  REASON_FAILURE_MESSAGE "SNMP not found. Please install NET SNMP library."
)
