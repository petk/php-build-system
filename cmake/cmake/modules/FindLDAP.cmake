#[=============================================================================[
Find the LDAP library.
https://en.wikipedia.org/wiki/List_of_LDAP_software
https://www.openldap.org/

If LDAP library is found, the following variables are set:

LDAP_FOUND
  Set to 1 if LDAP library is found.
LDAP_INCLUDE_DIRS
  A list of include directories for using LDAP library.
LDAP_LIBRARIES
  A list of libraries for using LDAP library.
LDAP_VERSION
  Version string of found LDAP library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(LDAP_FIND_VERSION)
    set(_pkg_module_spec "ldap>=${LDAP_FIND_VERSION}")
  else()
    set(_pkg_module_spec "ldap")
  endif()

  pkg_search_module(LDAP QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  LDAP
  REQUIRED_VARS LDAP_LIBRARIES
  VERSION_VAR LDAP_VERSION
  REASON_FAILURE_MESSAGE "LDAP not found. Please install LDAP library (libldap)."
)
