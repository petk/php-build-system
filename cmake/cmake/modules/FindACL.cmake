#[=============================================================================[
Find the ACL library.

Module defines the following IMPORTED target(s):

  ACL::ACL
    The package library, if found.

Result variables:

  ACL_FOUND
    Whether the package has been found.
  ACL_INCLUDE_DIRS
    Include directories needed to use this package.
  ACL_LIBRARIES
    Libraries needed to link to the package library.
  ACL_VERSION
    Package version, if found.

Cache variables:

  ACL_INCLUDE_DIR
    Directory containing package library headers.
  ACL_LIBRARY
    The path to the package library.

Hints:

  The ACL_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  ACL
  PROPERTIES
    URL "https://savannah.nongnu.org/projects/acl/"
    DESCRIPTION "POSIX Access Control Lists library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_ACL QUIET libacl)

find_path(
  ACL_INCLUDE_DIR
  NAMES sys/acl.h
  PATHS ${PC_ACL_INCLUDE_DIRS}
  DOC "Directory containing ACL library headers"
)

if(NOT ACL_INCLUDE_DIR)
  string(APPEND _reason "sys/acl.h not found. ")
endif()

find_library(
  ACL_LIBRARY
  NAMES acl
  PATHS ${PC_ACL_LIBRARY_DIRS}
  DOC "The path to the ACL library"
)

if(NOT ACL_LIBRARY)
  string(APPEND _reason "ACL library not found. ")
endif()

# Get version.
block(PROPAGATE ACL_VERSION)
  # ACL headers don't provide version. Try pkgconf version, if found.
  if(PC_ACL_VERSION)
    cmake_path(COMPARE "${ACL_INCLUDE_DIR}" EQUAL "${PC_ACL_INCLUDEDIR}" isEqual)

    if(isEqual)
      set(ACL_VERSION ${PC_ACL_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(ACL_INCLUDE_DIR ACL_LIBRARY)

find_package_handle_standard_args(
  ACL
  REQUIRED_VARS
    ACL_LIBRARY
    ACL_INCLUDE_DIR
  VERSION_VAR ACL_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT ACL_FOUND)
  return()
endif()

set(ACL_INCLUDE_DIRS ${ACL_INCLUDE_DIR})
set(ACL_LIBRARIES ${ACL_LIBRARY})

if(NOT TARGET ACL::ACL)
  add_library(ACL::ACL UNKNOWN IMPORTED)

  set_target_properties(
    ACL::ACL
    PROPERTIES
      IMPORTED_LOCATION "${ACL_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${ACL_INCLUDE_DIR}"
  )
endif()
