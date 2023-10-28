#[=============================================================================[
Find the Firebird library.

Module defines the following IMPORTED targets:

  Firebird::Firebird
    The Firebird library, if found.

Result variables:

  Firebird_FOUND
    Set to 1 if Firebird has been found.
  Firebird_INCLUDE_DIRS
    A list of include directories for using Firebird library.
  Firebird_LIBRARIES
    A list of libraries for linking when using Firebird library.
  Firebird_VERSION
    Version of Firebird if fb-config utility is available.
  Firebird_CONFIG_EXECUTABLE
    Path to the fb_config Firebird command-line utility.

Hints:

  The Firebird_ROOT variable adds search path for finding the Firebird on custom
  locations.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Firebird PROPERTIES
  URL "https://firebirdsql.org/"
  DESCRIPTION "SQL relational database management system"
)

find_path(Firebird_INCLUDE_DIRS ibase.h)

find_library(
  Firebird_LIBRARIES
  NAMES fbclient gds ib_util
  DOC "The Firebird library"
)

find_program(Firebird_CONFIG_EXECUTABLE fb_config)

if(Firebird_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND ${Firebird_CONFIG_EXECUTABLE} --version
    OUTPUT_VARIABLE Firebird_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
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

mark_as_advanced(Firebird_LIBRARIES Firebird_INCLUDE_DIRS)

find_package_handle_standard_args(
  Firebird
  REQUIRED_VARS
    Firebird_LIBRARIES
    Firebird_INCLUDE_DIRS
    _firebird_have_isc_detach_database
  VERSION_VAR Firebird_VERSION
)

if(Firebird_FOUND AND NOT TARGET Firebird::Firebird)
  add_library(Firebird::Firebird INTERFACE IMPORTED)

  set_target_properties(Firebird::Firebird PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Firebird_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Firebird_INCLUDE_DIRS}"
  )
endif()
