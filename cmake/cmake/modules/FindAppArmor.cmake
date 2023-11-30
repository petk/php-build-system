#[=============================================================================[
Find the AppArmor library.

Module defines the following IMPORTED targets:

  AppArmor::AppArmor
    The AppArmor library, if found.

Result variables:

  AppArmor_FOUND
    Whether AppArmor library is found.
  AppArmor_INCLUDE_DIRS
    A list of include directories for using AppArmor library.
  AppArmor_LIBRARIES
    A list of libraries for using AppArmor library.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(AppArmor PROPERTIES
  URL "https://apparmor.net/"
  DESCRIPTION "Kernel security module library to confine programs"
)

set(_reason_failure_message)

find_path(
  AppArmor_INCLUDE_DIRS
  NAMES sys/apparmor.h
  DOC "The AppArmor include directories"
)

if(NOT AppArmor_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    The sys/apparmor.h could not be found."
  )
endif()

find_library(AppArmor_LIBRARIES NAMES apparmor DOC "The AppArmor library")

if(NOT AppArmor_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    AppArmor not found. Please install the AppArmor library."
  )
endif()

# Sanity check.
if(AppArmor_LIBRARIES)
  check_library_exists(
    "${AppArmor_LIBRARIES}"
    aa_change_profile
    ""
    _apparmor_sanity_check
  )
endif()

if(NOT _apparmor_sanity_check)
  string(
    APPEND _reason_failure_message
    "\n    Sanity check failed. The aa_change_profile could not be found in "
    "the AppArmor library."
  )
endif()

find_package_handle_standard_args(
  AppArmor
  REQUIRED_VARS AppArmor_LIBRARIES AppArmor_INCLUDE_DIRS _apparmor_sanity_check
  REASON_FAILURE_MESSAGE "${reason_failure_message}"
)

unset(_reason_failure_message)

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
