#[=============================================================================[
Find the SASL library.

Module defines the following IMPORTED targets:

  SASL::SASL
    The SASL library, if found.

Result variables:

  SASL_FOUND
    Set to 1 if SASL library is found.
  SASL_INCLUDE_DIRS
    A list of include directories for using SASL library.
  SASL_LIBRARIES
    A list of libraries for using SASL library.
  SASL_VERSION
    Version string of found SASL library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(SASL PROPERTIES
  URL "https://www.cyrusimap.org/sasl/"
  DESCRIPTION "Simple authentication and security layer library"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(SASL_FIND_VERSION)
    set(_pkg_module_spec "libsasl2>=${SASL_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libsasl2")
  endif()

  pkg_search_module(SASL QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  SASL
  REQUIRED_VARS SASL_LIBRARIES
  VERSION_VAR SASL_VERSION
  REASON_FAILURE_MESSAGE "SASL not found. Please install SASL library (libsasl2)."
)

if(SASL_FOUND AND NOT TARGET SASL::SASL)
  add_library(SASL::SASL INTERFACE IMPORTED)

  set_target_properties(SASL::SASL PROPERTIES
    INTERFACE_LINK_LIBRARIES "${SASL_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${SASL_INCLUDE_DIRS}"
  )
endif()
