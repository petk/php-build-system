#[=============================================================================[
Find the libavif library.

This is a helper in case system doesn't have the library's Config find module.

Module defines the following IMPORTED targets:

  libavif::libavif
    The libavif library, if found.

Result variables:

  libavif_FOUND
    Whether libavif is found.
  libavif_INCLUDE_DIRS
    A list of include directories for using libavif.
  libavif_LIBRARIES
    A list of libraries for using libavif.
  libavif_VERSION
    Version string of found libavif.

Hints:

  The libavif_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(libavif PROPERTIES
  URL "https://github.com/AOMediaCodec/libavif"
  DESCRIPTION "Library for encoding and decoding .avif files"
)

set(_reason_failure_message)

find_path(libavif_INCLUDE_DIRS NAMES avif/avif.h)

if(NOT libavif_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    avif/avif.h not found."
  )
endif()

find_library(libavif_LIBRARIES NAMES avif DOC "The libavif library")

if(NOT libavif_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    libavif not found. Please install the libavif library."
  )
endif()

block(PROPAGATE libavif_VERSION)
  if(libavif_INCLUDE_DIRS)
    file(
      STRINGS "${libavif_INCLUDE_DIRS}/avif/avif.h"
      results
      REGEX "^#[ \t]*define[ \t]+AVIF_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[^\r\n]*$"
    )

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+AVIF_VERSION_${item}[ \t]+([0-9]+)[^\r\n]*$")
          if(DEFINED libavif_VERSION)
            string(APPEND libavif_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(libavif_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  libavif
  REQUIRED_VARS libavif_LIBRARIES libavif_INCLUDE_DIRS
  VERSION_VAR libavif_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(libavif_FOUND AND NOT TARGET libavif::libavif)
  add_library(libavif::libavif INTERFACE IMPORTED)

  set_target_properties(libavif::libavif PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${libavif_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${libavif_LIBRARIES}"
  )
endif()
