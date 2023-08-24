#[=============================================================================[
CMake module to find and use WEBP library.

If libwebp is found, the following variables are set:

WEBP_FOUND
  Set to 1 if libwebp is found.
WEBP_LIBRARIES
  A list of libraries for using libwebp.
WEBP_INCLUDE_DIRS
  A list of include directories for using libwebp.
WEBP_VERSION
  Version string of found libwebp.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(WEBP_FIND_VERSION)
    set(_pkg_module_spec "libwebp>=${WEBP_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libwebp")
  endif()

  pkg_search_module(WEBP QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  WEBP
  REQUIRED_VARS WEBP_LIBRARIES
  VERSION_VAR WEBP_VERSION
  REASON_FAILURE_MESSAGE "WEBP not found. Please install libwebp."
)
