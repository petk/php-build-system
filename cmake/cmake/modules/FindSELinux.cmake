#[=============================================================================[
Find the SELinux library.

Module defines the following IMPORTED targets:

  SELinux::SELinux
    The SELinux library, if found.

Result variables:

  SELinux_FOUND
    Whether SELinux library is found.
  SELinux_INCLUDE_DIRS
    A list of include directories for using SELinux library.
  SELinux_LIBRARIES
    A list of libraries for using SELinux library.

Hints:

  The SELinux_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(SELinux PROPERTIES
  URL "http://selinuxproject.org/"
  DESCRIPTION "Security Enhanced Linux"
)

set(_reason_failure_message)

find_path(SELinux_INCLUDE_DIRS selinux/selinux.h DOC "SELinux include directories")

if(NOT SELinux_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    The selinux/selinux.h could not be found."
  )
endif()

find_library(SELinux_LIBRARIES NAMES selinux DOC "SELinux library")

if(NOT SELinux_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    SELinux not found. Please install SELinux library (libselinux)."
  )
endif()

# Sanity check.
if(SELinux_LIBRARIES)
  check_library_exists(
    "${SELinux_LIBRARIES}"
    security_setenforce
    ""
    _selinux_sanity_check
  )
endif()

if(NOT _selinux_sanity_check)
  string(
    APPEND _reason_failure_message
    "\n    Sanity check failed. The security_setenforce() could not be found "
    "in the SELinux library."
  )
endif()

find_package_handle_standard_args(
  SELinux
  REQUIRED_VARS SELinux_LIBRARIES _selinux_sanity_check SELinux_INCLUDE_DIRS
  REASON_FAILURE_MESSAGE "${reason_failure_message}"
)

unset(_reason_failure_message)

if(SELinux_FOUND AND NOT TARGET SELinux::SELinux)
  add_library(SELinux::SELinux INTERFACE IMPORTED)

  set_target_properties(SELinux::SELinux PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SELinux_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${SELinux_LIBRARIES}"
  )
endif()
