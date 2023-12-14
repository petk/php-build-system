#[=============================================================================[
Find the Oniguruma library.

Module defines the following IMPORTED targets:

  Oniguruma::Oniguruma
    The Oniguruma library, if found.

Result variables:

  Oniguruma_FOUND
    Whether Oniguruma library is found.
  Oniguruma_INCLUDE_DIRS
    A list of include directories for using Oniguruma library.
  Oniguruma_LIBRARIES
    A list of libraries for using Oniguruma library.
  Oniguruma_VERSION
    Version string of found Oniguruma library.

Hints:

  The Oniguruma_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Oniguruma PROPERTIES
  URL "https://github.com/kkos/oniguruma"
  DESCRIPTION "Regular expression library"
)

set(_reason_failure_message)

find_path(Oniguruma_INCLUDE_DIRS NAMES oniguruma.h)

if(NOT Oniguruma_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    oniguruma.h not found."
  )
endif()

find_library(Oniguruma_LIBRARIES NAMES onig DOC "The Oniguruma library")

if(NOT Oniguruma_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Oniguruma not found. Please install the Oniguruma library (libonig)."
  )
endif()

block(PROPAGATE Oniguruma_VERSION)
  if(Oniguruma_INCLUDE_DIRS)
    file(
      STRINGS
      "${Oniguruma_INCLUDE_DIRS}/oniguruma.h"
      strings
      REGEX
      "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_(MAJOR|MINOR|TEENY)[ \t]+[0-9]+[ \t]*$"
    )

    foreach(item MAJOR MINOR TEENY)
      foreach(line ${strings})
        if(line MATCHES "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(Oniguruma_VERSION)
            string(APPEND Oniguruma_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Oniguruma_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  Oniguruma
  REQUIRED_VARS Oniguruma_LIBRARIES Oniguruma_INCLUDE_DIRS
  VERSION_VAR Oniguruma_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

mark_as_advanced(Oniguruma_INCLUDE_DIRS Oniguruma_LIBRARIES)

if(Oniguruma_FOUND AND NOT TARGET Oniguruma::Oniguruma)
  add_library(Oniguruma::Oniguruma INTERFACE IMPORTED)

  set_target_properties(Oniguruma::Oniguruma PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Oniguruma_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Oniguruma_LIBRARIES}"
  )
endif()
