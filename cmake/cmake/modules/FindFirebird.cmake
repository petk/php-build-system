#[=============================================================================[
Find the Firebird library.

Module defines the following IMPORTED targets:

  Firebird::Firebird
    The Firebird library, if found.

Result variables:

  Firebird_FOUND
    Whether Firebird has been found.
  Firebird_INCLUDE_DIRS
    A list of include directories for using Firebird library.
  Firebird_LIBRARIES
    A list of libraries for linking when using Firebird library.
  Firebird_VERSION
    Version of Firebird if fb-config utility is available.
  Firebird_CONFIG_EXECUTABLE
    Path to the fb_config Firebird command-line utility.

Hints:

  The Firebird_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Firebird PROPERTIES
  URL "https://firebirdsql.org/"
  DESCRIPTION "SQL relational database management system"
)

set(_reason_failure_message)

find_path(Firebird_INCLUDE_DIRS ibase.h)

if(NOT Firebird_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    ibase.h not found."
  )
endif()

find_library(
  Firebird_LIBRARIES
  NAMES fbclient gds ib_util
  DOC "The Firebird library"
)

if(NOT Firebird_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Firebird not found. Please install Firebird."
  )
endif()

find_program(Firebird_CONFIG_EXECUTABLE fb_config)

if(Firebird_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND ${Firebird_CONFIG_EXECUTABLE} --version
    OUTPUT_VARIABLE Firebird_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
endif()

if(Firebird_VERSION)
  set(_firebird_version_argument VERSION_VAR Firebird_VERSION)
endif()

# Sanity check.
if(Firebird_LIBRARIES)
  check_library_exists(
    "${Firebird_LIBRARIES}"
    isc_detach_database
    ""
    _firebird_have_isc_detach_database
  )
endif()

if(NOT _firebird_have_isc_detach_database)
  string(
    APPEND _reason_failure_message
    "\n    Firebird sanity check failed, isc_detach_database couldn't be found."
  )
endif()

mark_as_advanced(
  Firebird_LIBRARIES
  Firebird_INCLUDE_DIRS
  Firebird_CONFIG_EXECUTABLE
)

find_package_handle_standard_args(
  Firebird
  REQUIRED_VARS
    Firebird_LIBRARIES
    Firebird_INCLUDE_DIRS
    _firebird_have_isc_detach_database
  ${_firebird_version_argument}
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)
unset(_firebird_version_argument)

if(Firebird_FOUND AND NOT TARGET Firebird::Firebird)
  add_library(Firebird::Firebird INTERFACE IMPORTED)

  set_target_properties(Firebird::Firebird PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Firebird_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Firebird_LIBRARIES}"
  )
endif()
