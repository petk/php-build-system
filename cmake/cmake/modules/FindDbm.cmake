#[=============================================================================[
Find the dbm library.

Depending on the system, the dbm library can be part of other libraries as an
interface.

Module defines the following IMPORTED targets:

  Dbm::Dbm
    The dbm library, if found.

Result variables:

  Dbm_FOUND
    Set to 1 if dbm has been found.
  Dbm_INCLUDE_DIRS
    A list of include directories for using dbm library.
  Dbm_LIBRARIES
    A list of libraries for linking when using dbm library.
  Dbm_IMPLEMENTATION
    String of the library name that implements the dbm library.

Hints:

  The Dbm_ROOT variable adds search path for finding the dbm on custom
  location.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Dbm PROPERTIES
  URL "https://en.wikipedia.org/wiki/DBM_(computing)"
  DESCRIPTION "A key-value database library"
)

find_path(Dbm_INCLUDE_DIRS dbm.h PATH_SUFFIXES gdbm)

# TODO: Fix the search names and the sanity check.
find_library(Dbm_LIBRARIES NAMES gdbm_compat DOC "The dbm library")

if(Dbm_LIBRARIES)
  set(Dbm_IMPLEMENTATION "GDBM")
else()
  find_library(Dbm_LIBRARIES NAMES dbm c DOC "The dbm library")
  set(Dbm_IMPLEMENTATION "DBM")
endif()

mark_as_advanced(Dbm_LIBRARIES Dbm_INCLUDE_DIRS)

# Sanity check.
check_library_exists("${Dbm_LIBRARIES}" dbminit "" HAVE_DBMINIT)

find_package_handle_standard_args(
  Dbm
  REQUIRED_VARS Dbm_LIBRARIES Dbm_INCLUDE_DIRS HAVE_DBMINIT
)

if(NOT Dbm_FOUND)
  return()
endif()

if(NOT TARGET Dbm::Dbm)
  add_library(Dbm::Dbm INTERFACE IMPORTED)

  set_target_properties(Dbm::Dbm PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Dbm_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Dbm_INCLUDE_DIRS}"
  )
endif()
