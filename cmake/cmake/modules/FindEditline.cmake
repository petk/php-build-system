#[=============================================================================[
Find the Editline library.

Module defines the following IMPORTED targets:

  Editline::Editline
    The Editline library, if found.

Result variables:

  Editline_FOUND
    Whether Editline library is found.
  Editline_INCLUDE_DIRS
    A list of include directories for using Editline library.
  Editline_LIBRARIES
    A list of libraries for using Editline library.
  Editline_VERSION
    Version string of found Editline library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Editline PROPERTIES
  URL "https://thrysoee.dk/editline/"
  DESCRIPTION "Command-line editor library for generic line editing, history, and tokenization"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(Editline_FIND_VERSION)
    set(_pkg_module_spec "libedit>=${Editline_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libedit")
  endif()

  pkg_search_module(Editline QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Editline
  REQUIRED_VARS Editline_LIBRARIES
  VERSION_VAR Editline_VERSION
  REASON_FAILURE_MESSAGE "Editline not found. Please install Editline library (libedit)."
)

if(Editline_FOUND AND NOT TARGET Editline::Editline)
  add_library(Editline::Editline INTERFACE IMPORTED)

  set_target_properties(Editline::Editline PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Editline_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Editline_INCLUDE_DIRS}"
  )
endif()
