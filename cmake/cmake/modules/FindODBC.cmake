#[=============================================================================[
Find the ODBC library.

Module defines the following IMPORTED targets:

  ODBC::ODBC
    The ODBC library, if found.

Result variables:

  ODBC_FOUND
    Whether ODBC has been found.
  ODBC_INCLUDE_DIRS
    A list of include directories for using ODBC library.
  ODBC_LIBRARIES
    A list of libraries for linking when using ODBC library.

Hints:

  The ODBC_ROOT variable adds custom search path.

  The ODBC_LIBRARY can be overridden.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(ODBC PROPERTIES
  URL "https://en.wikipedia.org/wiki/Open_Database_Connectivity"
  DESCRIPTION "Open Database Connectivity library"
)

find_path(ODBC_INCLUDE_DIRS sql.h)

set(_reason_failure_message)

if(NOT ODBC_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    ODBC include directory not found."
  )
endif()

find_library(ODBC_LIBRARY NAMES odbc DOC "The ODBC library")

if(NOT ODBC_LIBRARY)
  string(
    APPEND _reason_failure_message
    "\n    ODBC library not found."
  )
endif()

set(ODBC_LIBRARIES ${ODBC_LIBRARY})

mark_as_advanced(ODBC_LIBRARY ODBC_INCLUDE_DIRS)

find_package_handle_standard_args(
  ODBC
  REQUIRED_VARS
    ODBC_LIBRARIES
    ODBC_INCLUDE_DIRS
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(NOT ODBC_FOUND)
  return()
endif()

if(NOT TARGET ODBC::ODBC)
  add_library(ODBC::ODBC INTERFACE IMPORTED)

  set_target_properties(ODBC::ODBC PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ODBC_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${ODBC_LIBRARIES}"
  )
endif()
