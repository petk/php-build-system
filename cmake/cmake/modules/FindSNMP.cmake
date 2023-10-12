#[=============================================================================[
Find the NET SNMP library.
http://www.net-snmp.org/

Module defines the following IMPORTED targets:

  SNPM::SNMP
    The SNMP library, if found.

Result variables:

  SNMP_FOUND
    Set to 1 if NET SNMP library is found.
  SNMP_INCLUDE_DIRS
    A list of include directories for using NET SNMP library.
  SNMP_LIBRARIES
    A list of libraries for using NET SNMP library.
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
  REASON_FAILURE_MESSAGE "SNMP not found. Please install NET SNMP library (libsnmp)."
)

if(SNMP_FOUND AND NOT TARGET SNMP::SNMP)
  add_library(SNMP::SNMP INTERFACE IMPORTED)

  set_target_properties(SNMP::SNMP PROPERTIES
    INTERFACE_LINK_LIBRARIES "${SNMP_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${SNMP_INCLUDE_DIRS}"
  )
endif()
