#[=============================================================================[
CMake module to find and use Kerberos library.

Module sets the following variables:

KERBEROS_FOUND
  Set to 1 if Kerberos library has been found.
KERBEROS_INCLUDE_DIRS
  A list of include directories for using Kerberos library.
KERBEROS_LIBRARIES
  A list of libraries for linking when using Kerberos.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  pkg_search_module(KERBEROS krb5-gssapi krb5)
endif()

find_package_handle_standard_args(
  KERBEROS
  REQUIRED_VARS KERBEROS_LIBRARIES KERBEROS_INCLUDE_DIRS
  VERSION_VAR KERBEROS_VERSION
  REASON_FAILURE_MESSAGE "Kerberos not found. Please install Kerberos library (libkrb)."
)
