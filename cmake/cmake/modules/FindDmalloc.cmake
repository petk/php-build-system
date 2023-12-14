#[=============================================================================[
Find the Dmalloc library.

Module defines the following IMPORTED targets:

  Dmalloc::Dmalloc
    The Dmalloc library, if found.

Result variables:

  Dmalloc_FOUND
    Whether Dmalloc library is found.
  Dmalloc_INCLUDE_DIRS
    A list of include directories for using Dmalloc library.
  Dmalloc_LIBRARIES
    A list of libraries for using Dmalloc library.
  Dmalloc_VERSION
    Version string of found Dmalloc library.

Hints:

  The Dmalloc_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Dmalloc PROPERTIES
  URL "https://dmalloc.com/"
  DESCRIPTION "Debug Malloc Library"
)

set(_reason_failure_message)

find_path(Dmalloc_INCLUDE_DIRS dmalloc.h)

if(NOT Dmalloc_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    dmalloc.h not found."
  )
endif()

find_library(Dmalloc_LIBRARIES NAMES dmalloc DOC "The Dmalloc library")

if(NOT Dmalloc_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Dmalloc library not found. Please install the Dmalloc library."
  )
endif()

block(PROPAGATE Dmalloc_VERSION)
  if(Dmalloc_INCLUDE_DIRS)
    file(
      STRINGS
      "${Dmalloc_INCLUDE_DIRS}/dmalloc.h"
      strings
      REGEX
      "^#[ \t]*define[ \t]+DMALLOC_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*[^\r\n]*$"
    )

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${strings})
        if(line MATCHES "^#[ \t]*define[ \t]+DMALLOC_VERSION_${item}[ \t]+([0-9]+)[ \t]*[^\r\n]*$")
          if(Dmalloc_VERSION)
            string(APPEND Dmalloc_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Dmalloc_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  Dmalloc
  REQUIRED_VARS Dmalloc_LIBRARIES Dmalloc_INCLUDE_DIRS
  VERSION_VAR Dmalloc_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Dmalloc_FOUND AND NOT TARGET Dmalloc::Dmalloc)
  add_library(Dmalloc::Dmalloc INTERFACE IMPORTED)

  set_target_properties(Dmalloc::Dmalloc PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Dmalloc_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Dmalloc_LIBRARIES}"
  )
endif()
