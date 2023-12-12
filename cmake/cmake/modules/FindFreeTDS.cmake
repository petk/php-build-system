#[=============================================================================[
Find the FreeTDS set of libraries.

Module defines the following IMPORTED targets:

  FreeTDS::FreeTDS
    The FreeTDS library, if found.

Result variables:

  FreeTDS_FOUND
    Whether FreeTDS has been found.
  FreeTDS_INCLUDE_DIRS
    A list of include directories for using FreeTDS set of libraries.
  FreeTDS_LIBRARIES
    A list of libraries for linking when using FreeTDS library.

Hints:

  The FreeTDS_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(FreeTDS PROPERTIES
  URL "https://www.freetds.org/"
  DESCRIPTION "TDS (Tabular DataStream) protocol library for Sybase and MS SQL"
)

find_path(FreeTDS_INCLUDE_DIRS sybdb.h PATH_SUFFIXES freetds)

set(_reason_failure_message)

if(NOT FreeTDS_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    FreeTDS include directory not found."
  )
endif()

find_library(FreeTDS_LIBRARIES NAMES sybdb DOC "The FreeTDS library")

if(NOT FreeTDS_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    FreeTDS library not found."
  )
endif()

# Sanity check.
if(FreeTDS_LIBRARIES)
  check_library_exists(
    "${FreeTDS_LIBRARIES}"
    dbsqlexec
    ""
    FreeTDS_HAVE_DBSQLEXEC
  )
endif()

if(NOT FreeTDS_HAVE_DBSQLEXEC)
  string(
    APPEND _reason_failure_message
    "\n    The dbsqlexec was not found in the FreeTDS library."
  )
endif()

mark_as_advanced(FreeTDS_LIBRARIES FreeTDS_INCLUDE_DIRS)

find_package_handle_standard_args(
  FreeTDS
  REQUIRED_VARS FreeTDS_LIBRARIES FreeTDS_INCLUDE_DIRS FreeTDS_HAVE_DBSQLEXEC
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(FreeTDS_FOUND AND NOT TARGET FreeTDS::FreeTDS)
  add_library(FreeTDS::FreeTDS INTERFACE IMPORTED)

  set_target_properties(FreeTDS::FreeTDS PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FreeTDS_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${FreeTDS_LIBRARIES}"
  )
endif()
