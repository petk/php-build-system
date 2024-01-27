#[=============================================================================[
Find the Firebird library.

Module defines the following IMPORTED target(s):

  Firebird::Firebird
    The package library, if found.

Result variables:

  Firebird_FOUND
    Whether the package has been found.
  Firebird_INCLUDE_DIRS
    Include directories needed to use this package.
  Firebird_LIBRARIES
    Libraries needed to link to the package library.
  Firebird_VERSION
    Version of Firebird if fb-config utility is available.

Cache variables:

  Firebird_INCLUDE_DIR
    Directory containing package library headers.
  Firebird_LIBRARY
    The path to the package library.
  Firebird_CONFIG_EXECUTABLE
    Path to the fb_config Firebird command-line utility.

Hints:

  The Firebird_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Firebird
  PROPERTIES
    URL "https://firebirdsql.org/"
    DESCRIPTION "SQL relational database management system"
)

set(_reason "")

find_path(
  Firebird_INCLUDE_DIR
  NAMES ibase.h
  DOC "Directory containing Firebird library headers"
)

if(NOT Firebird_INCLUDE_DIR)
  string(APPEND _reason "ibase.h not found. ")
endif()

find_library(
  Firebird_LIBRARY
  NAMES fbclient gds ib_util
  DOC "The path to the Firebird library"
)

if(NOT Firebird_LIBRARY)
  string(APPEND _reason "Firebird library not found. ")
endif()

find_program(
  Firebird_CONFIG_EXECUTABLE
  NAMES fb_config
  DOC "Path to the fb_config Firebird command-line utility"
)

if(Firebird_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${Firebird_CONFIG_EXECUTABLE}" --version
    OUTPUT_VARIABLE Firebird_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

# Sanity check.
if(Firebird_LIBRARY)
  check_library_exists(
    "${Firebird_LIBRARY}"
    isc_detach_database
    ""
    _firebird_sanity_check
  )
endif()

if(NOT _firebird_sanity_check)
  string(APPEND _reason "Sanity check failed: isc_detach_database not found. ")
endif()

mark_as_advanced(
  Firebird_CONFIG_EXECUTABLE
  Firebird_INCLUDE_DIR
  Firebird_LIBRARY
)

find_package_handle_standard_args(
  Firebird
  REQUIRED_VARS
    Firebird_LIBRARY
    Firebird_INCLUDE_DIR
    _firebird_sanity_check
  VERSION_VAR Firebird_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Firebird_FOUND)
  return()
endif()

set(Firebird_INCLUDE_DIRS ${Firebird_INCLUDE_DIR})
set(Firebird_LIBRARIES ${Firebird_LIBRARY})

if(NOT TARGET Firebird::Firebird)
  add_library(Firebird::Firebird UNKNOWN IMPORTED)

  set_target_properties(
    Firebird::Firebird
    PROPERTIES
      IMPORTED_LOCATION "${Firebird_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Firebird_INCLUDE_DIR}"
  )
endif()
