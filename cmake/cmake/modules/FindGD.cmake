#[=============================================================================[
Find the GD library.

Module defines the following IMPORTED targets:

  GD::GD
    The GD library, if found.

Result variables:

  GD_FOUND
    Whether libgd is found.
  GD_INCLUDE_DIRS
    A list of include directories for using libgd.
  GD_LIBRARIES
    A list of libraries for using libgd.
  GD_VERSION
    Version string of found libgd.

Hints:

  The GD_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(GD PROPERTIES
  URL "https://libgd.github.io/"
  DESCRIPTION "Library for dynamic creation of images"
)

set(_reason_failure_message)

find_path(GD_INCLUDE_DIRS gd.h)

if(NOT GD_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    gd.h not found."
  )
endif()

find_library(GD_LIBRARIES NAMES gd DOC "The GD library")

if(NOT GD_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    GD not found. Please install GD library (libgd)."
  )
endif()

# Get version.
block(PROPAGATE GD_VERSION)
  if(GD_INCLUDE_DIRS)
    file(
      STRINGS
      "${GD_INCLUDE_DIRS}/gd.h"
      results
      REGEX
      "^#[ \t]*define[ \t]+GD_(MAJOR|MINOR|RELEASE)_VERSION[ \t]+[0-9]+[ \t]*[^\r\n]*$"
    )

    foreach(item MAJOR MINOR RELEASE)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+GD_${item}_VERSION[ \t]+([0-9]+)[ \t]*[^\r\n]*$")
          if(GD_VERSION)
            string(APPEND GD_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(GD_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  GD
  REQUIRED_VARS GD_LIBRARIES GD_INCLUDE_DIRS
  VERSION_VAR GD_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(GD_FOUND AND NOT TARGET GD::GD)
  add_library(GD::GD INTERFACE IMPORTED)

  set_target_properties(GD::GD PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GD_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${GD_LIBRARIES}"
  )
endif()
