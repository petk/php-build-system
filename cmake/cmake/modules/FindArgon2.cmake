#[=============================================================================[
Find the Argon2 library.
https://github.com/P-H-C/phc-winner-argon2/

Module defines the following IMPORTED targets:

  Argon2::Argon2
    The Argon2 library, if found.

Result variables:

  Argon2_FOUND
    Set to 1 if Argon2 library is found.
  Argon2_INCLUDE_DIRS
    A list of include directories for using Argon2 library.
  Argon2_LIBRARIES
    A list of libraries for using Argon2 library.
  Argon2_VERSION
    Version string of Argon2 library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(Argon2_FIND_VERSION)
    set(_pkg_module_spec "libargon2>=${Argon2_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libargon2")
  endif()

  pkg_search_module(Argon2 QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Argon2
  REQUIRED_VARS Argon2_LIBRARIES
  VERSION_VAR Argon2_VERSION
  REASON_FAILURE_MESSAGE "Argon2 not found. Please install Argon2 library."
)

if(Argon2_FOUND AND NOT TARGET Argon2::Argon2)
  add_library(Argon2::Argon2 INTERFACE IMPORTED)

  set_target_properties(Argon2::Argon2 PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Argon2_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Argon2_INCLUDE_DIRS}"
  )
endif()
