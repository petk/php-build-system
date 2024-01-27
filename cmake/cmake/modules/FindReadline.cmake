#[=============================================================================[
Find the GNU Readline library.

Module defines the following IMPORTED target(s):

  Readline::Readline
    The package library, if found.

Result variables:

  Readline_FOUND
    Whether the package has been found.
  Readline_INCLUDE_DIRS
    Include directories needed to use this package.
  Readline_LIBRARIES
    Libraries needed to link to the package library.
  Readline_VERSION
    Package version, if found.

Cache variables:

  Readline_INCLUDE_DIR
    Directory containing package library headers.
  Readline_LIBRARY
    The path to the package library.

Hints:

  The Readline_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Readline
  PROPERTIES
    URL "https://tiswww.case.edu/php/chet/readline/rltop.html"
    DESCRIPTION "GNU Readline library for command-line editing"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Readline QUIET readline)

find_path(
  Readline_INCLUDE_DIR
  NAMES readline/readline.h
  PATHS ${PC_Readline_INCLUDE_DIRS}
  DOC "Directory containing Readline library headers"
)

if(NOT Readline_INCLUDE_DIR)
  string(APPEND _reason "readline/readline.h not found. ")
endif()

find_library(
  Readline_LIBRARY
  NAMES readline
  PATHS ${PC_Readline_LIBRARY_DIRS}
  DOC "The path to the Readline library"
)

if(NOT Readline_LIBRARY)
  string(APPEND _reason "Readline library not found. ")
endif()

if(Readline_LIBRARY)
  # Sanity check.
  check_library_exists(
    "${Readline_LIBRARY}"
    readline
    ""
    _readline_have_readline
  )

  if(NOT _readline_have_readline)
    string(APPEND _reason "Sanity check failed: readline() not found. ")
  endif()

  # Library version check.
  check_library_exists(
    "${Readline_LIBRARY}"
    rl_pending_input
    ""
    _readline_have_rl_pending_input
  )

  if(NOT _readline_have_rl_pending_input)
    string(
      APPEND _reason
      "Invalid Readline library detected. Try EditLine instead. "
    )
  endif()
endif()

# Get version.
block(PROPAGATE Readline_VERSION)
  if(Readline_INCLUDE_DIR)
    file(
      STRINGS
      "${Readline_INCLUDE_DIR}/readline/readline.h"
      results
      REGEX
      "^#[ \t]*define[ \t]+RL_VERSION_(MAJOR|MINOR)[ \t]+[0-9]+[ \t]*$"
    )

    unset(Readline_VERSION)

    foreach(item MAJOR MINOR)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+RL_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED Readline_VERSION)
            string(APPEND Readline_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Readline_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(Readline_INCLUDE_DIR Readline_LIBRARY)

find_package_handle_standard_args(
  Readline
  REQUIRED_VARS
    Readline_LIBRARY
    Readline_INCLUDE_DIR
    _readline_have_readline
    _readline_have_rl_pending_input
  VERSION_VAR Readline_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Readline_FOUND)
  return()
endif()

set(Readline_INCLUDE_DIRS ${Readline_INCLUDE_DIR})
set(Readline_LIBRARIES ${Readline_LIBRARY})

if(NOT TARGET Readline::Readline)
  add_library(Readline::Readline UNKNOWN IMPORTED)

  set_target_properties(
    Readline::Readline
    PROPERTIES
      IMPORTED_LOCATION "${Readline_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Readline_INCLUDE_DIR}"
  )
endif()
