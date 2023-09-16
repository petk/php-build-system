#[=============================================================================[
Find the Sodium library (libsodium).
https://libsodium.org/

Module sets the following variables:

SODIUM_FOUND
  Set to 1 if Sodium library is found.
SODIUM_INCLUDE_DIRS
  A list of include directories for using Sodium library.
SODIUM_LIBRARIES
  A list of libraries for linking when using Sodium library.
SODIUM_VERSION
  Version string of found Sodium library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  pkg_search_module(SODIUM libsodium)
endif()

if(SODIUM_FOUND)
  set(SODIUM_LIBRARIES ${SODIUM_LIBRARIES})
  set(SODIUM_INCLUDE_DIRS ${SODIUM_INCLUDE_DIRS})
endif()

find_package_handle_standard_args(
  SODIUM
  REQUIRED_VARS SODIUM_LIBRARIES
  VERSION_VAR SODIUM_VERSION
)
