#[=============================================================================[
CMake module to find and use oniguruma library.

If oniguruma library is found, the following variables are set:

ONIGURUMA_FOUND
  Set to 1 if oniguruma library is found.
ONIGURUMA_LIBRARIES
  A list of libraries for using oniguruma library.
ONIGURUMA_INCLUDE_DIRS
  A list of include directories for using oniguruma library.
ONIGURUMA_VERSION
  Version string of found oniguruma library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(ONIGURUMA_FIND_VERSION)
    set(_pkg_module_spec "oniguruma>=${ONIGURUMA_FIND_VERSION}")
  else()
    set(_pkg_module_spec "oniguruma")
  endif()

  pkg_search_module(ONIGURUMA QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  ONIGURUMA
  REQUIRED_VARS ONIGURUMA_LIBRARIES
  VERSION_VAR ONIGURUMA_VERSION
  REASON_FAILURE_MESSAGE "ONIGURUMA not found. Please install oniguruma library."
)
