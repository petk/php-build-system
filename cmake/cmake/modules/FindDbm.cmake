#[=============================================================================[
Find the dbm library.

Depending on the system, the dbm library can be part of other libraries as an
interface.

Module defines the following IMPORTED target(s):

  Dbm::Dbm
    The package library, if found.

Result variables:

  Dbm_FOUND
    Whether the package has been found.
  Dbm_INCLUDE_DIRS
    Include directories needed to use this package.
  Dbm_LIBRARIES
    Libraries needed to link to the package library.
  Dbm_IMPLEMENTATION
    String of the library name that implements the dbm library.

Cache variables:

  Dbm_INCLUDE_DIR
    Directory containing package library headers.
  Dbm_LIBRARY
    The path to the package library.

Hints:

  The Dbm_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Dbm
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/DBM_(computing)"
    DESCRIPTION "A key-value database library"
)

set(_reason "")

find_path(
  Dbm_INCLUDE_DIR
  NAMES dbm.h
  PATH_SUFFIXES gdbm
  DOC "Directory containing dbm library headers"
)

if(NOT Dbm_INCLUDE_DIR)
  string(APPEND _reason "dbm.h not found. ")
endif()

# TODO: Fix the search names and the sanity check.
find_library(
  Dbm_LIBRARY
  NAMES gdbm_compat
  DOC "The path to the dbm compat library"
)

if(Dbm_LIBRARY)
  set(Dbm_IMPLEMENTATION "GDBM")
else()
  find_library(
    Dbm_LIBRARY
    NAMES dbm c
    DOC "The path to the dbm library"
  )
  set(Dbm_IMPLEMENTATION "DBM")
endif()

if(NOT Dbm_LIBRARY)
  string(APPEND _reason "dbm library not found. ")
endif()

# Sanity check.
if(Dbm_LIBRARY)
  check_library_exists("${Dbm_LIBRARY}" dbminit "" _dbm_sanity_check)

  if(NOT _dbm_sanity_check)
    string(APPEND _reason "Sanity check failed: dbminit not found. ")
  endif()
endif()

mark_as_advanced(Dbm_INCLUDE_DIR Dbm_LIBRARY)

find_package_handle_standard_args(
  Dbm
  REQUIRED_VARS
    Dbm_LIBRARY
    Dbm_INCLUDE_DIR
    _dbm_sanity_check
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Dbm_FOUND)
  return()
endif()

set(Dbm_INCLUDE_DIRS ${Dbm_INCLUDE_DIR})
set(Dbm_LIBRARIES ${Dbm_LIBRARY})

if(NOT TARGET Dbm::Dbm)
  add_library(Dbm::Dbm UNKNOWN IMPORTED)

  set_target_properties(
    Dbm::Dbm
    PROPERTIES
      IMPORTED_LOCATION "${Dbm_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Dbm_INCLUDE_DIR}"
  )
endif()
