#[=============================================================================[
Find the LDAP library.

Module defines the following IMPORTED targets:

  LDAP::LDAP
    The LDAP library, if found.

Result variables:

  LDAP_FOUND
    Whether LDAP library is found.
  LDAP_INCLUDE_DIRS
    A list of include directories for using LDAP library.
  LDAP_LIBRARIES
    A list of libraries for using LDAP library.
  LDAP_VERSION
    Version string of found LDAP library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(LDAP PROPERTIES
  URL "https://www.openldap.org/"
  DESCRIPTION "Lightweight directory access protocol library"
  PURPOSE "https://en.wikipedia.org/wiki/List_of_LDAP_software"
)

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

if(LDAP_FOUND AND NOT TARGET LDAP::LDAP)
  add_library(LDAP::LDAP INTERFACE IMPORTED)

  set_target_properties(LDAP::LDAP PROPERTIES
    INTERFACE_LINK_LIBRARIES "${LDAP_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${LDAP_INCLUDE_DIRS}"
  )
endif()
