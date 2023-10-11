#[=============================================================================[
Find the Capstone library.
https://www.capstone-engine.org

This module defines the following IMPORTED target:

  Capstone::Capstone
    The Capstone library, if found.

If Capstone library is found, the following variables are set:

  Capstone_FOUND
    Set to 1 if Capstone library is found.
  Capstone_INCLUDE_DIRS
    A list of include directories for using Capstone library.
  Capstone_LIBRARIES
    A list of libraries for using Capstone library.
  Capstone_VERSION
    Version string of found Capstone library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(Capstone_FIND_VERSION)
    set(_pkg_module_spec "capstone>=${Capstone_FIND_VERSION}")
  else()
    set(_pkg_module_spec "capstone")
  endif()

  pkg_search_module(Capstone QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Capstone
  REQUIRED_VARS Capstone_LIBRARIES
  VERSION_VAR Capstone_VERSION
  REASON_FAILURE_MESSAGE "Capstone not found. Please install the Capstone library."
)

if(Capstone_FOUND AND NOT TARGET Capstone::Capstone)
  add_library(Capstone::Capstone INTERFACE IMPORTED)

  set_target_properties(Capstone::Capstone PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Capstone_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Capstone_INCLUDE_DIRS}"
  )
endif()
