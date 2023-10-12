#[=============================================================================[
Find the libavif library.
https://github.com/AOMediaCodec/libavif

This is a helper in case system doesn't have the library's Config find module.

Module defines the following IMPORTED targets:

  libavif::libavif
    The libavif library, if found.

Result variables:

  libavif_FOUND
    Set to 1 if libavif is found.
  libavif_INCLUDE_DIRS
    A list of include directories for using libavif.
  libavif_LIBRARIES
    A list of libraries for using libavif.
  libavif_VERSION
    Version string of found libavif.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(libavif_FIND_VERSION)
    set(_pkg_module_spec "libavif>=${libavif_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libavif")
  endif()

  pkg_search_module(libavif QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  libavif
  REQUIRED_VARS libavif_LIBRARIES
  VERSION_VAR libavif_VERSION
  REASON_FAILURE_MESSAGE "libavif not found. Please install the libavif library."
)

if(libavif_FOUND AND NOT TARGET libavif::libavif)
  add_library(libavif::libavif INTERFACE IMPORTED)

  set_target_properties(libavif::libavif PROPERTIES
    INTERFACE_LINK_LIBRARIES "${libavif_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${libavif_INCLUDE_DIRS}"
  )
endif()
