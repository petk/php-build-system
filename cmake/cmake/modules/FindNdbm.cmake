#[=============================================================================[
Find the ndbm library.

Depending on the system, the nbdm library can be part of other libraries as an
interface.

Module defines the following IMPORTED targets:

  Ndbm::Ndbm
    The ndbm library, if found.

Result variables:

  Ndbm_FOUND
    Whether ndbm has been found.
  Ndbm_INCLUDE_DIRS
    A list of include directories for using ndbm library.
  Ndbm_LIBRARIES
    A list of libraries for linking when using ndbm library.

Hints:

  The Ndbm_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Ndbm PROPERTIES
  URL "https://en.wikipedia.org/wiki/DBM_(computing)"
  DESCRIPTION "A new dbm library"
)

set(_reason_failure_message)

find_path(Ndbm_INCLUDE_DIRS ndbm.h PATH_SUFFIXES db1)

if(NOT Ndbm_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    ndbm.h not found."
  )
endif()

# TODO: Fix the search names and the sanity check.
find_library(Ndbm_LIBRARIES NAMES ndbm db1 gdbm_compat c DOC "The ndbm library")

if(NOT Ndbm_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    NDBM library not found. Please install the NDBM library."
  )
endif()

mark_as_advanced(Ndbm_LIBRARIES Ndbm_INCLUDE_DIRS)

# Sanity check.
if(Ndbm_LIBRARIES)
  check_library_exists("${Ndbm_LIBRARIES}" dbm_open "" HAVE_DBM_OPEN)
endif()

find_package_handle_standard_args(
  Ndbm
  REQUIRED_VARS Ndbm_LIBRARIES Ndbm_INCLUDE_DIRS HAVE_DBM_OPEN
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(NOT Ndbm_FOUND)
  return()
endif()

if(NOT TARGET Ndbm::Ndbm)
  add_library(Ndbm::Ndbm INTERFACE IMPORTED)

  set_target_properties(Ndbm::Ndbm PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Ndbm_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Ndbm_LIBRARIES}"
  )
endif()
