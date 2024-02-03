#[=============================================================================[
Find the Tokyo Cabinet library.

Module defines the following IMPORTED target(s):

  TokyoCabinet::TokyoCabinet
    The package library, if found.

Result variables:

  TokyoCabinet_FOUND
    Whether the package has been found.
  TokyoCabinet_INCLUDE_DIRS
    Include directories needed to use this package.
  TokyoCabinet_LIBRARIES
    Libraries needed to link to the package library.
  TokyoCabinet_VERSION
    Package version, if found.

Cache variables:

  TokyoCabinet_INCLUDE_DIR
    Directory containing package library headers.
  TokyoCabinet_LIBRARY
    The path to the package library.

Hints:

  The TokyoCabinet_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  TokyoCabinet
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/Tkrzw"
    DESCRIPTION "Key-value database library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_TokyoCabinet QUIET tokyocabinet)

find_path(
  TokyoCabinet_INCLUDE_DIR
  NAMES tcadb.h
  PATHS ${PC_TokyoCabinet_INCLUDE_DIRS}
  DOC "Directory containing Tokyo Cabinet library headers"
)

if(NOT TokyoCabinet_INCLUDE_DIR)
  string(APPEND _reason "tcadb.h not found. ")
endif()

find_library(
  TokyoCabinet_LIBRARY
  NAMES tokyocabinet
  PATHS ${PC_TokyoCabinet_LIBRARY_DIRS}
  DOC "The path to the Tokyo Cabinet library"
)

if(NOT TokyoCabinet_LIBRARY)
  string(APPEND _reason "Tokyo Cabinet library not found. ")
endif()

# Sanity check.
if(TokyoCabinet_LIBRARY)
  check_library_exists(
    "${TokyoCabinet_LIBRARY}"
    tcadbopen
    ""
    _tokyocabinet_sanity_check
  )

  if(NOT _tokyocabinet_sanity_check)
    string(APPEND _reason "Sanity check failed: tcadbopen not found. ")
  endif()
endif()

# Get version.
block(PROPAGATE TokyoCabinet_VERSION)
  if(TokyoCabinet_INCLUDE_DIR AND EXISTS ${TokyoCabinet_INCLUDE_DIR}/tcutil.h)
    set(regex [[^[ \t]*#[ \t]*define[ \t]+_TC_VERSION[ \t]+"?([0-9.]+)"?[ \t]*$]])

    file(STRINGS ${TokyoCabinet_INCLUDE_DIR}/tcutil.h results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(TokyoCabinet_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()
endblock()

mark_as_advanced(TokyoCabinet_INCLUDE_DIR TokyoCabinet_LIBRARY)

find_package_handle_standard_args(
  TokyoCabinet
  REQUIRED_VARS
    TokyoCabinet_LIBRARY
    TokyoCabinet_INCLUDE_DIR
    _tokyocabinet_sanity_check
  VERSION_VAR TokyoCabinet_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT TokyoCabinet_FOUND)
  return()
endif()

set(TokyoCabinet_INCLUDE_DIRS ${TokyoCabinet_INCLUDE_DIR})
set(TokyoCabinet_LIBRARIES ${TokyoCabinet_LIBRARY})

if(NOT TARGET TokyoCabinet::TokyoCabinet)
  add_library(TokyoCabinet::TokyoCabinet UNKNOWN IMPORTED)

  set_target_properties(
    TokyoCabinet::TokyoCabinet
    PROPERTIES
      IMPORTED_LOCATION "${TokyoCabinet_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${TokyoCabinet_INCLUDE_DIR}"
  )
endif()
