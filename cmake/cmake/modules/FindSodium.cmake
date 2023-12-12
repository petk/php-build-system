#[=============================================================================[
Find the Sodium library (libsodium).

Module defines the following IMPORTED targets:

  Sodium::Sodium
    The Sodium library, if found.

Result variables:

  Sodium_FOUND
    Whether Sodium library is found.
  Sodium_INCLUDE_DIRS
    A list of include directories for using Sodium library.
  Sodium_LIBRARIES
    A list of libraries for linking when using Sodium library.
  Sodium_VERSION
    Version string of found Sodium library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Sodium PROPERTIES
  URL "https://libsodium.org/"
  DESCRIPTION "Crypto library"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(Sodium_FIND_VERSION)
    set(_pkg_module_spec "libsodium>=${Sodium_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libsodium")
  endif()

  pkg_search_module(Sodium QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Sodium
  REQUIRED_VARS Sodium_LIBRARIES
  VERSION_VAR Sodium_VERSION
)

if(Sodium_FOUND AND NOT TARGET Sodium::Sodium)
  add_library(Sodium::Sodium INTERFACE IMPORTED)

  set_target_properties(Sodium::Sodium PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Sodium_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Sodium_LIBRARIES}"
  )
endif()
