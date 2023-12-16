#[=============================================================================[
Find the Kerberos library.

Deprecated.

TODO: Fine tune the imported library by finding krb headers and link with
gssapi and krb5.

Module defines the following IMPORTED targets:

  Kerberos::Kerberos

Result variables:

  Kerberos_FOUND
    Whether Kerberos library has been found.
  Kerberos_INCLUDE_DIRS
    A list of include directories for using Kerberos library.
  Kerberos_LIBRARIES
    A list of libraries for linking when using Kerberos library.
  Kerberos_VERSION
    Version string of Kerberos library.

Hints:

  TODO: The Kerberos_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Kerberos PROPERTIES
  URL "https://web.mit.edu/kerberos/"
  DESCRIPTION "The Network Authentication Protocol"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  pkg_search_module(Kerberos krb5-gssapi krb5)
endif()

find_package_handle_standard_args(
  Kerberos
  REQUIRED_VARS Kerberos_LIBRARIES Kerberos_INCLUDE_DIRS
  VERSION_VAR Kerberos_VERSION
  REASON_FAILURE_MESSAGE "Kerberos not found. Please install Kerberos library (libkrb)."
)

if(Kerberos_FOUND AND NOT TARGET Kerberos::Kerberos)
  add_library(Kerberos::Kerberos INTERFACE IMPORTED)

  set_target_properties(Kerberos::Kerberos PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Kerberos_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Kerberos_LIBRARIES}"
  )
endif()
