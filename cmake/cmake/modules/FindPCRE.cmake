#[=============================================================================[
Find the PCRE library.

Module defines the following IMPORTED targets:

  PCRE::PCRE
    The PCRE library, if found.

Result variables:

  PCRE_FOUND
    Whether PCRE library is found.
  PCRE_INCLUDE_DIRS
    A list of include directories for using PCRE library.
  PCRE_LIBRARIES
    A list of libraries for using PCRE library.
  PCRE_VERSION
    Version string of found PCRE library.

Hints:

  The PCRE_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(PCRE PROPERTIES
  URL "https://www.pcre.org/"
  DESCRIPTION "Perl compatible regular expressions library"
)

set(_reason_failure_message)

find_path(PCRE_INCLUDE_DIRS NAMES pcre2.h DOC "PCRE library include directory")

if(NOT PCRE_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    PCRE include directory not found."
  )
endif()

find_library(PCRE_LIBRARIES NAMES pcre2-8 DOC "The PCRE library")

if(NOT PCRE_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    PCRE library not found."
  )
endif()

block(PROPAGATE PCRE_VERSION)
  if(PCRE_INCLUDE_DIRS)
    file(
      STRINGS "${PCRE_INCLUDE_DIRS}/pcre2.h"
      results
      REGEX "^#[ \t]*define[ \t]+PCRE2_(MAJOR|MINOR)[ \t]+[0-9]+[^\r\n]*$"
    )

    foreach(item MAJOR MINOR)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+PCRE2_${item}[ \t]+([0-9]+)[^\r\n]*$")
          if(DEFINED PCRE_VERSION)
            string(APPEND PCRE_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(PCRE_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  PCRE
  REQUIRED_VARS PCRE_LIBRARIES PCRE_INCLUDE_DIRS
  VERSION_VAR PCRE_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(PCRE_FOUND AND NOT TARGET PCRE::PCRE)
  add_library(PCRE::PCRE INTERFACE IMPORTED)

  set_target_properties(PCRE::PCRE PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PCRE_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${PCRE_LIBRARIES}"
  )
endif()
