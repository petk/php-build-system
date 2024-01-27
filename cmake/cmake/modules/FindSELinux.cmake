#[=============================================================================[
Find the SELinux library.

Module defines the following IMPORTED target(s):

  SELinux::SELinux
    The package library, if found.

Result variables:

  SELinux_FOUND
    Whether the package has been found.
  SELinux_INCLUDE_DIRS
    Include directories needed to use this package.
  SELinux_LIBRARIES
    Libraries needed to link to the package library.
  SELinux_VERSION
    Package version, if found.

Cache variables:

  SELinux_INCLUDE_DIR
    Directory containing package library headers.
  SELinux_LIBRARY
    The path to the package library.

Hints:

  The SELinux_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  SELinux
  PROPERTIES
    URL "http://selinuxproject.org/"
    DESCRIPTION "Security Enhanced Linux"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Selinux QUIET libselinux)

find_path(
  SELinux_INCLUDE_DIR
  NAMES selinux/selinux.h
  PATHS ${PC_Selinux_INCLUDE_DIRS}
  DOC "Directory containing SELinux library headers"
)

if(NOT SELinux_INCLUDE_DIR)
  string(APPEND _reason "selinux/selinux.h not found. ")
endif()

find_library(
  SELinux_LIBRARY
  NAMES selinux
  PATHS ${PC_Selinux_LIBRARY_DIRS}
  DOC "The path to the SELinux library"
)

if(NOT SELinux_LIBRARY)
  string(APPEND _reason "SELinux library (libselinux) not found. ")
endif()

# Sanity check.
if(SELinux_LIBRARY)
  check_library_exists(
    "${SELinux_LIBRARY}"
    security_setenforce
    ""
    _selinux_sanity_check
  )

  if(NOT _selinux_sanity_check)
    string(APPEND _reason "Sanity check failed: security_setenforce() not found. ")
  endif()
endif()

# Get version.
block(PROPAGATE SELinux_VERSION)
  # SELinux headers don't provide version. Try pkgconf version, if found.
  if(PC_SELinux_VERSION)
    cmake_path(
      COMPARE
      "${PC_SELinux_INCLUDEDIR}" EQUAL "${SELinux_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(SELinux_VERSION ${PC_SELinux_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(SELinux_INCLUDE_DIR SELinux_LIBRARY)

find_package_handle_standard_args(
  SELinux
  REQUIRED_VARS
    SELinux_LIBRARY
    SELinux_INCLUDE_DIR
    _selinux_sanity_check
  VERSION_VAR SELinux_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT SELinux_FOUND)
  return()
endif()

set(SELinux_INCLUDE_DIRS ${SELinux_INCLUDE_DIR})
set(SELinux_LIBRARIES ${SELinux_LIBRARY})

if(NOT TARGET SELinux::SELinux)
  add_library(SELinux::SELinux UNKNOWN IMPORTED)

  set_target_properties(
    SELinux::SELinux
    PROPERTIES
      IMPORTED_LOCATION "${SELinux_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${SELinux_INCLUDE_DIR}"
  )
endif()
