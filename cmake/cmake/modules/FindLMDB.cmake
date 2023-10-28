#[=============================================================================[
Find the LMDB library.

Module defines the following IMPORTED targets:

  LMDB::LMDB
    The LMDB library, if found.

Result variables:

  LMDB_FOUND
    Set to 1 if LMDB has been found.
  LMDB_INCLUDE_DIRS
    A list of include directories for using LMDB library.
  LMDB_LIBRARIES
    A list of libraries for linking when using LMDB library.

Hints:

  The LMDB_ROOT variable adds search path for finding the LMDB on custom
  location.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(LMDB PROPERTIES
  URL "https://www.symas.com/lmdb"
  DESCRIPTION "Lightning Memory-Mapped Database library"
)

find_path(LMDB_INCLUDE_DIRS lmdb.h)

find_library(LMDB_LIBRARIES NAMES lmdb DOC "The LMDB library")

mark_as_advanced(LMDB_LIBRARIES LMDB_INCLUDE_DIRS)

# Sanity check.
check_library_exists("${LMDB_LIBRARIES}" mdb_env_open "" HAVE_MDB_ENV_OPEN)

find_package_handle_standard_args(
  LMDB
  REQUIRED_VARS LMDB_LIBRARIES LMDB_INCLUDE_DIRS HAVE_MDB_ENV_OPEN
)

if(NOT LMDB_FOUND)
  return()
endif()

if(NOT TARGET LMDB::LMDB)
  add_library(LMDB::LMDB INTERFACE IMPORTED)

  set_target_properties(LMDB::LMDB PROPERTIES
    INTERFACE_LINK_LIBRARIES "${LMDB_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${LMDB_INCLUDE_DIRS}"
  )
endif()
