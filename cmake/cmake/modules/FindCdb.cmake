#[=============================================================================[
Find the cdb library.

Module defines the following IMPORTED targets:

  Cdb::Cdb
    The cdb library, if found.

Result variables:

  Cdb_FOUND
    Whether cdb has been found.
  Cdb_INCLUDE_DIRS
    A list of include directories for using cdb library.
  Cdb_LIBRARIES
    A list of libraries for linking when using cdb library.

Hints:

  The Cdb_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Cdb PROPERTIES
  URL "https://en.wikipedia.org/wiki/Cdb_(software)"
  DESCRIPTION "A constant database library"
)

find_path(Cdb_INCLUDE_DIRS cdb.h)

find_library(Cdb_LIBRARIES NAMES cdb DOC "The cdb library")

mark_as_advanced(Cdb_LIBRARIES Cdb_INCLUDE_DIRS)

# Sanity check.
check_library_exists("${Cdb_LIBRARIES}" cdb_read "" HAVE_CDB_READ)

find_package_handle_standard_args(
  Cdb
  REQUIRED_VARS Cdb_LIBRARIES Cdb_INCLUDE_DIRS HAVE_CDB_READ
)

if(NOT Cdb_FOUND)
  return()
endif()

if(NOT TARGET Cdb::Cdb)
  add_library(Cdb::Cdb INTERFACE IMPORTED)

  set_target_properties(Cdb::Cdb PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Cdb_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Cdb_INCLUDE_DIRS}"
  )
endif()
