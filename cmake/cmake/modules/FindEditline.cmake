#[=============================================================================[
Find the Editline library.

Module defines the following IMPORTED targets:

  Editline::Editline
    The Editline library, if found.

Result variables:

  Editline_FOUND
    Whether Editline library is found.
  Editline_INCLUDE_DIRS
    A list of include directories for using Editline library.
  Editline_LIBRARIES
    A list of libraries for using Editline library.

Hints:

  The Editline_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Editline PROPERTIES
  URL "https://thrysoee.dk/editline/"
  DESCRIPTION "Command-line editor library for generic line editing, history, and tokenization"
)

find_path(Editline_INCLUDE_DIRS readline.h PATH_SUFFIXES editline)

find_library(Editline_LIBRARIES NAMES edit DOC "The Editline library")

# Sanity check.
if(Editline_LIBRARIES)
  check_library_exists(
    "${Editline_LIBRARIES}"
    readline
    ""
    _editline_have_readline
  )
endif()

set(_reason_failure_message)

if(NOT Editline_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    Include directory not found. Please install Editline library."
  )
endif()

if(NOT Editline_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Editline library not found."
  )
endif()

if(NOT _editline_have_readline)
  string(
    APPEND _reason_failure_message
    "\n    Editline sanity check failed - readline() not found in library."
  )
endif()

find_package_handle_standard_args(
  Editline
  REQUIRED_VARS Editline_LIBRARIES Editline_INCLUDE_DIRS _editline_have_readline
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Editline_FOUND AND NOT TARGET Editline::Editline)
  add_library(Editline::Editline INTERFACE IMPORTED)

  set_target_properties(Editline::Editline PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Editline_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Editline_INCLUDE_DIRS}"
  )
endif()
