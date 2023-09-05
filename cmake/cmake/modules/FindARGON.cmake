#[=============================================================================[
CMake module to find and use the Argon2 library.
https://github.com/P-H-C/phc-winner-argon2/

If Argon2 library is found, the following variables are set:

ARGON_FOUND
  Set to 1 if Argon2 library is found.
ARGON_LIBRARIES
  A list of libraries for using Argon2 library.
ARGON_INCLUDE_DIRS
  A list of include directories for using Argon2 library.
ARGON_VERSION
  Version string of found Argon2 library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(ARGON_FIND_VERSION)
    set(_pkg_module_spec "libargon2>=${ARGON_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libargon2")
  endif()

  pkg_search_module(ARGON QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  ARGON
  REQUIRED_VARS ARGON_LIBRARIES
  VERSION_VAR ARGON_VERSION
  REASON_FAILURE_MESSAGE "ARGON not found. Please install Argon2 library."
)
