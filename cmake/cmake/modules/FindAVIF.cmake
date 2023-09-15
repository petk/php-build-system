#[=============================================================================[
Find the AVIF library.

If AVIF library is found, the following variables are set:

AVIF_FOUND
  Set to 1 if libavif is found.
AVIF_INCLUDE_DIRS
  A list of include directories for using libavif.
AVIF_LIBRARIES
  A list of libraries for using libavif.
AVIF_VERSION
  Version string of found libavif.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(AVIF_FIND_VERSION)
    set(_pkg_module_spec "libavif>=${AVIF_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libavif")
  endif()

  pkg_search_module(AVIF QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  AVIF
  REQUIRED_VARS AVIF_LIBRARIES
  VERSION_VAR AVIF_VERSION
  REASON_FAILURE_MESSAGE "AVIF not found. Please install AVIF library (libavif)."
)
