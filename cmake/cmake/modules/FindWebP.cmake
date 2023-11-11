#[=============================================================================[
Find the libwebp library.

Module defines the following IMPORTED targets:

  WebP::WebP
    The libwebp library, if found.

Result variables:

  WebP_FOUND
    Whether libwebp is found.
  WebP_INCLUDE_DIRS
    A list of include directories for using libwebp.
  WebP_LIBRARIES
    A list of libraries for using libwebp.
  WebP_VERSION
    Version string of found libwebp.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(WebP PROPERTIES
  URL "https://developers.google.com/speed/webp/"
  DESCRIPTION "Library for the WebP graphics format"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(WebP_FIND_VERSION)
    set(_pkg_module_spec "libwebp>=${WebP_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libwebp")
  endif()

  pkg_search_module(WebP QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  WebP
  REQUIRED_VARS WebP_LIBRARIES
  VERSION_VAR WebP_VERSION
  REASON_FAILURE_MESSAGE "WebP not found. Please install the libwebp library."
)

if(WebP_FOUND AND NOT TARGET WebP::WebP)
  add_library(WebP::WebP INTERFACE IMPORTED)

  set_target_properties(WebP::WebP PROPERTIES
    INTERFACE_LINK_LIBRARIES "${WebP_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIRS}"
  )
endif()
