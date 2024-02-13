#[=============================================================================[
Find the ODBC library.

Module defines the following IMPORTED target(s):

  ODBC::ODBC
    The package library, if found.

Result variables:

  ODBC_FOUND
    Whether the package has been found.
  ODBC_INCLUDE_DIRS
    Include directories needed to use this package.
  ODBC_LIBRARIES
    Libraries needed to link to the package library.
  ODBC_VERSION
    Package version, if found.

Cache variables:

  ODBC_INCLUDE_DIR
    Directory containing package library headers.
  ODBC_LIBRARY
    The path to the package library.

Hints:

  The ODBC_ROOT variable adds custom search path.

  The ODBC_TYPE variable adds ODBC library name to look for.
    TODO: Fix this better.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  ODBC
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/Open_Database_Connectivity"
    DESCRIPTION "Open Database Connectivity library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_ODBC QUIET odbc)

find_path(
  ODBC_INCLUDE_DIR
  NAMES sql.h
  PATHS ${PC_ODBC_INCLUDE_DIRS}
  DOC "Directory containing ODBC library headers"
)

if(NOT ODBC_INCLUDE_DIR)
  string(APPEND _reason "ODBC sql.h not found. ")
endif()

find_library(
  ODBC_LIBRARY
  NAMES ${ODBC_TYPE} odbc
  PATHS ${PC_ODBC_LIBRARY_DIRS}
  DOC "The path to the ODBC library"
)

if(NOT ODBC_LIBRARY)
  string(APPEND _reason "ODBC library not found. ")
endif()

# Get version.
block(PROPAGATE ODBC_VERSION)
  # ODBC headers don't provide version. Try pkgconf version, if found.
  if(PC_ODBC_VERSION)
    cmake_path(
      COMPARE
      "${PC_ODBC_INCLUDEDIR}" EQUAL "${ODBC_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(ODBC_VERSION ${PC_ODBC_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(ODBC_LIBRARY ODBC_INCLUDE_DIR)

find_package_handle_standard_args(
  ODBC
  REQUIRED_VARS
    ODBC_LIBRARY
    ODBC_INCLUDE_DIR
  VERSION_VAR ODBC_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT ODBC_FOUND)
  return()
endif()

set(ODBC_INCLUDE_DIRS ${ODBC_INCLUDE_DIR})
set(ODBC_LIBRARIES ${ODBC_LIBRARY})

if(NOT TARGET ODBC::ODBC)
  add_library(ODBC::ODBC UNKNOWN IMPORTED)

  set_target_properties(
    ODBC::ODBC
    PROPERTIES
      IMPORTED_LOCATION "${ODBC_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${ODBC_INCLUDE_DIR}"
  )
endif()
