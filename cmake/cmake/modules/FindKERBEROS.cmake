#[=============================================================================[
CMake module to find and use Kerberos library.
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
  REASON_FAILURE_MESSAGE "Kerberos not found. Please install libkrb."
)
