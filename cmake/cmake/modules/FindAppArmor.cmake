#[=============================================================================[
Find the AppArmor library.

Module defines the following IMPORTED targets:

  AppArmor::AppArmor
    The AppArmor library, if found.

Result variables:

  AppArmor_FOUND
    Set to 1 if AppArmor library is found.
  AppArmor_INCLUDE_DIRS
    A list of include directories for using AppArmor library.
  AppArmor_LIBRARIES
    A list of libraries for using AppArmor library.
  AppArmor_VERSION
    Version string of found AppArmor library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(AppArmor PROPERTIES
  URL "https://apparmor.net/"
  DESCRIPTION "Kernel security module library to confine programs to a limited set of resources"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(AppArmor_FIND_VERSION)
    set(_pkg_module_spec "libapparmor>=${AppArmor_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libapparmor")
  endif()

  pkg_search_module(AppArmor QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  AppArmor
  REQUIRED_VARS AppArmor_LIBRARIES
  VERSION_VAR AppArmor_VERSION
  REASON_FAILURE_MESSAGE "AppArmor not found. Please install the AppArmor library."
)

if(NOT AppArmor_FOUND)
  return()
endif()

if(NOT TARGET AppArmor::AppArmor)
  add_library(AppArmor::AppArmor INTERFACE IMPORTED)

  set_target_properties(AppArmor::AppArmor PROPERTIES
    INTERFACE_LINK_LIBRARIES "${AppArmor_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${AppArmor_INCLUDE_DIRS}"
  )
endif()
