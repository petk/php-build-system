#[=============================================================================[
Find the GNU Readline library.

Module defines the following IMPORTED targets:

  Readline::Readline
    The Readline library, if found.

Result variables:

  Readline_FOUND
    Whether GNU Readline library is found.
  Readline_INCLUDE_DIRS
    A list of include directories for using GNU Readline library.
  Readline_LIBRARIES
    A list of libraries for using GNU Readline library.
  Readline_VERSION
    Version string of found GNU Readline library.

Hints:

  The Readline_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Readline PROPERTIES
  URL "https://tiswww.case.edu/php/chet/readline/rltop.html"
  DESCRIPTION "GNU Readline library for command-line editing"
)

find_path(Readline_INCLUDE_DIRS readline.h PATH_SUFFIXES readline)

find_library(Readline_LIBRARIES NAMES readline DOC "The Readline library")

if(Readline_LIBRARIES)
  # Sanity check.
  check_library_exists(
    "${Readline_LIBRARIES}"
    readline
    ""
    _readline_have_readline
  )

  # Library version check.
  check_library_exists(
    "${Readline_LIBRARIES}"
    rl_pending_input
    ""
    _readline_have_rl_pending_input
  )
endif()

set(_reason_failure_message)

if(NOT Readline_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    Include directory not found. Please install Readline library."
  )
endif()

if(NOT Readline_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Readline library not found."
  )
endif()

if(NOT _readline_have_readline)
  string(
    APPEND _reason_failure_message
    "\n    Readline sanity check failed - readline() not found in library."
  )
endif()

if(NOT _readline_have_rl_pending_input)
  string(
    APPEND _reason_failure_message
    "\n    Invalid Readline library detected. Try EditLine instead."
  )
endif()

# Get version.
if(Readline_INCLUDE_DIRS)
  unset(Readline_VERSION)

  file(
    STRINGS
    "${Readline_INCLUDE_DIRS}/readline.h"
    _readline_version_string
    REGEX
    "^#[ \t]*define[ \t]+RL_VERSION_(MAJOR|MINOR)[ \t]+[0-9]+[ \t]*$"
  )

  foreach(version_part MAJOR MINOR)
    foreach(version_line ${_readline_version_string})
      set(
        _readline_regex
        "^#[ \t]*define[ \t]+RL_VERSION_${version_part}[ \t]+([0-9]+)[ \t]*$"
      )

      if(version_line MATCHES "${_readline_regex}")
        if(Readline_VERSION)
          string(APPEND Readline_VERSION ".${CMAKE_MATCH_1}")
        else()
          set(Readline_VERSION "${CMAKE_MATCH_1}")
        endif()
      endif()
    endforeach()
  endforeach()

  unset(_readline_version_string)
endif()

find_package_handle_standard_args(
  Readline
  REQUIRED_VARS
    Readline_LIBRARIES
    Readline_INCLUDE_DIRS
    _readline_have_readline
    _readline_have_rl_pending_input
  VERSION_VAR Readline_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Readline_FOUND AND NOT TARGET Readline::Readline)
  add_library(Readline::Readline INTERFACE IMPORTED)

  set_target_properties(Readline::Readline PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Readline_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Readline_LIBRARIES}"
  )
endif()
