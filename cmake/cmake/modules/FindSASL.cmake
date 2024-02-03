#[=============================================================================[
Find the SASL library.

Module defines the following IMPORTED target(s):

  SASL::SASL
    The package library, if found.

Result variables:

  SASL_FOUND
    Whether the package has been found.
  SASL_INCLUDE_DIRS
    Include directories needed to use this package.
  SASL_LIBRARIES
    Libraries needed to link to the package library.
  SASL_VERSION
    Package version, if found.

Cache variables:

  SASL_INCLUDE_DIR
    Directory containing package library headers.
  SASL_LIBRARY
    The path to the package library.

Hints:

  The SASL_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  SASL
  PROPERTIES
    URL "https://www.cyrusimap.org/sasl/"
    DESCRIPTION "Simple authentication and security layer library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_SASL QUIET libsasl2)

find_path(
  SASL_INCLUDE_DIR
  NAMES sasl/sasl.h
  PATHS ${PC_SASL_INCLUDE_DIRS}
  DOC "Directory containing SASL library headers"
)

if(NOT SASL_INCLUDE_DIR)
  string(APPEND _reason "sasl/sasl.h not found. ")
endif()

find_library(
  SASL_LIBRARY
  NAMES sasl2
  PATHS ${PC_SASL_LIBRARY_DIRS}
  DOC "The path to the SASL library"
)

if(NOT SASL_LIBRARY)
  string(APPEND _reason "SASL library (libsasl2) not found. "
  )
endif()

block(PROPAGATE SASL_VERSION)
  if(SASL_INCLUDE_DIR)
    file(
      STRINGS
      ${SASL_INCLUDE_DIR}/sasl/sasl.h
      results
      REGEX
      "^#[ \t]*define[ \t]+SASL_VERSION_(MAJOR|MINOR|STEP)[ \t]+[0-9]+[ \t]*$"
    )

    unset(SASL_VERSION)

    foreach(item MAJOR MINOR STEP)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+SASL_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED SASL_VERSION)
            string(APPEND SASL_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(SASL_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(SASL_INCLUDE_DIR SASL_LIBRARY)

find_package_handle_standard_args(
  SASL
  REQUIRED_VARS
    SASL_LIBRARY
    SASL_INCLUDE_DIR
  VERSION_VAR SASL_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT SASL_FOUND)
  return()
endif()

set(SASL_INCLUDE_DIRS ${SASL_INCLUDE_DIR})
set(SASL_LIBRARIES ${SASL_LIBRARY})

if(NOT TARGET SASL::SASL)
  add_library(SASL::SASL UNKNOWN IMPORTED)

  set_target_properties(
    SASL::SASL
    PROPERTIES
      IMPORTED_LOCATION "${SASL_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${SASL_INCLUDE_DIR}"
  )
endif()
