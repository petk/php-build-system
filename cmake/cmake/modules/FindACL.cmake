#[=============================================================================[
Find the ACL library.

Module defines the following IMPORTED targets:

  ACL::ACL
    The ACL library, if found.

Result variables:

  ACL_FOUND
    Whether ACL library is found.
  ACL_INCLUDE_DIRS
    A list of include directories for using ACL library.
  ACL_LIBRARIES
    A list of libraries for using ACL library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(ACL PROPERTIES
  URL "https://savannah.nongnu.org/projects/acl/"
  DESCRIPTION "POSIX Access Control Lists library"
)

set(_reason_failure_message)

find_path(ACL_INCLUDE_DIRS sys/acl.h DOC "ACL include directories")

if(NOT ACL_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    The sys/acl.h could not be found."
  )
endif()

find_library(ACL_LIBRARIES NAMES acl DOC "ACL library")

if(NOT ACL_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    ACL not found. Please install the ACL library."
  )
endif()

find_package_handle_standard_args(
  ACL
  REQUIRED_VARS ACL_LIBRARIES ACL_INCLUDE_DIRS
  REASON_FAILURE_MESSAGE "${reason_failure_message}"
)

unset(_reason_failure_message)

if(NOT ACL_FOUND)
  return()
endif()

if(NOT TARGET ACL::ACL)
  add_library(ACL::ACL INTERFACE IMPORTED)

  set_target_properties(ACL::ACL PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ACL_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${ACL_LIBRARIES}"
  )
endif()
