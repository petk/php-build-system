#[=============================================================================[
Find the PCRE library.

Module defines the following `IMPORTED` target(s):

* `PCRE::PCRE` - The package library, if found.

Result variables:

* `PCRE_FOUND` - Whether the package has been found.
* `PCRE_INCLUDE_DIRS` - Include directories needed to use this package.
* `PCRE_LIBRARIES` - Libraries needed to link to the package library.
* `PCRE_VERSION` - Package version, if found.

Cache variables:

* `PCRE_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE_LIBRARY` - The path to the package library.

Hints:

The `PCRE_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  PCRE
  PROPERTIES
    URL "https://www.pcre.org/"
    DESCRIPTION "Perl compatible regular expressions library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_PCRE QUIET libpcre2-8)
endif()

find_path(
  PCRE_INCLUDE_DIR
  NAMES pcre2.h
  HINTS ${PC_PCRE_INCLUDE_DIRS}
  DOC "Directory containing PCRE library headers"
)

if(NOT PCRE_INCLUDE_DIR)
  string(APPEND _reason "pcre2.h not found. ")
endif()

find_library(
  PCRE_LIBRARY
  NAMES pcre2-8
  HINTS ${PC_PCRE_LIBRARY_DIRS}
  DOC "The path to the PCRE library"
)

if(NOT PCRE_LIBRARIES)
  string(APPEND _reason "PCRE library not found. ")
endif()

block(PROPAGATE PCRE_VERSION)
  if(PCRE_INCLUDE_DIR)
    file(
      STRINGS
      ${PCRE_INCLUDE_DIR}/pcre2.h
      results
      REGEX "^#[ \t]*define[ \t]+PCRE2_(MAJOR|MINOR)[ \t]+[0-9]+[^\r\n]*$"
    )

    unset(PCRE_VERSION)

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

mark_as_advanced(PCRE_INCLUDE_DIR PCRE_LIBRARY)

find_package_handle_standard_args(
  PCRE
  REQUIRED_VARS
    PCRE_LIBRARY
    PCRE_INCLUDE_DIR
  VERSION_VAR PCRE_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT PCRE_FOUND)
  return()
endif()

set(PCRE_INCLUDE_DIRS ${PCRE_INCLUDE_DIR})
set(PCRE_LIBRARIES ${PCRE_LIBRARY})

if(NOT TARGET PCRE::PCRE)
  add_library(PCRE::PCRE UNKNOWN IMPORTED)

  set_target_properties(
    PCRE::PCRE
    PROPERTIES
      IMPORTED_LOCATION "${PCRE_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${PCRE_INCLUDE_DIR}"
  )
endif()
