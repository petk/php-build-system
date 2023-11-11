#[=============================================================================[
Find the libzip library.

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

Module defines the following IMPORTED targets:

  libzip::libzip
    The libzip library, if found.

Result variables:

  libzip_FOUND
    Whether libzip library has been found.
  libzip_INCLUDE_DIRS
    A list of include directories for using libzip library.
  libzip_LIBRARIES
    A list of libraries for linking when using libzip library.
  libzip_VERSION
    Version string of the found libzip library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(libzip PROPERTIES
  URL "https://libzip.org/"
  DESCRIPTION "Library for handling ZIP archives"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(libzip_FIND_VERSION)
    set(_pkg_module_spec "libzip>=${libzip_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libzip")
  endif()

  pkg_search_module(libzip QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  libzip
  REQUIRED_VARS libzip_LIBRARIES
  VERSION_VAR libzip_VERSION
  REASON_FAILURE_MESSAGE "The libzip not found. Please install libzip library."
)

if(libzip_FOUND AND NOT TARGET libzip::libzip)
  add_library(libzip::libzip INTERFACE IMPORTED)

  set_target_properties(libzip::libzip PROPERTIES
    INTERFACE_LINK_LIBRARIES "${libzip_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${libzip_INCLUDE_DIRS}"
  )
endif()
