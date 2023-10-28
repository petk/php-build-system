#[=============================================================================[
Find the ACL library.

Module defines the following IMPORTED targets:

  ACL::ACL
    The ACL library, if found.

Result variables:

  ACL_FOUND
    Set to 1 if ACL library is found.
  ACL_INCLUDE_DIRS
    A list of include directories for using ACL library.
  ACL_LIBRARIES
    A list of libraries for using ACL library.
  ACL_VERSION
    Version string of found ACL library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(ACL PROPERTIES
  URL "https://savannah.nongnu.org/projects/acl/"
  DESCRIPTION "POSIX Access Control Lists library"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(ACL_FIND_VERSION)
    set(_pkg_module_spec "libacl>=${ACL_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libacl")
  endif()

  pkg_search_module(ACL QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  ACL
  REQUIRED_VARS ACL_LIBRARIES
  VERSION_VAR ACL_VERSION
  REASON_FAILURE_MESSAGE "ACL not found. Please install ACL library."
)

if(NOT ACL_FOUND)
  return()
endif()

if(NOT TARGET ACL::ACL)
  add_library(ACL::ACL INTERFACE IMPORTED)

  set_target_properties(ACL::ACL PROPERTIES
    INTERFACE_LINK_LIBRARIES "${ACL_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${ACL_INCLUDE_DIRS}"
  )
endif()
