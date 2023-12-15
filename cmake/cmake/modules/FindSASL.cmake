#[=============================================================================[
Find the SASL library.

Module defines the following IMPORTED targets:

  SASL::SASL
    The SASL library, if found.

Result variables:

  SASL_FOUND
    Whether SASL library is found.
  SASL_INCLUDE_DIRS
    A list of include directories for using SASL library.
  SASL_LIBRARIES
    A list of libraries for using SASL library.
  SASL_VERSION
    Version string of found SASL library.

Hints:

  The SASL_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(SASL PROPERTIES
  URL "https://www.cyrusimap.org/sasl/"
  DESCRIPTION "Simple authentication and security layer library"
)

set(_reason_failure_message)

find_path(SASL_INCLUDE_DIRS sasl/sasl.h)

if(NOT SASL_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    sasl/sasl.h not found."
  )
endif()

find_library(SASL_LIBRARIES NAMES sasl2 DOC "The SASL library")

if(NOT SASL_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    SASL not found. Please install SASL library (libsasl2)."
  )
endif()

block(PROPAGATE SASL_VERSION)
  if(SASL_INCLUDE_DIRS)
    file(
      STRINGS
      "${SASL_INCLUDE_DIRS}/sasl/sasl.h"
      results
      REGEX
      "^#[ \t]*define[ \t]+SASL_VERSION_(MAJOR|MINOR|STEP)[ \t]+[0-9]+[ \t]*$"
    )

    foreach(item MAJOR MINOR STEP)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+SASL_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(SASL_VERSION)
            string(APPEND SASL_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(SASL_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  SASL
  REQUIRED_VARS SASL_LIBRARIES SASL_INCLUDE_DIRS
  VERSION_VAR SASL_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(SASL_FOUND AND NOT TARGET SASL::SASL)
  add_library(SASL::SASL INTERFACE IMPORTED)

  set_target_properties(SASL::SASL PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SASL_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${SASL_LIBRARIES}"
  )
endif()
