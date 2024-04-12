#[=============================================================================[
Find the LDAP library.

Module defines the following IMPORTED target(s):

  LDAP::LDAP
    The LDAP library, if found.

  LDAP::LBER
    OpenLDAP LBER Lightweight Basic Encoding Rules library, if found. Linked to
    LDAP::LDAP.

Result variables:

  LDAP_FOUND
    Whether the package has been found.
  LDAP_INCLUDE_DIRS
    Include directories needed to use this package.
  LDAP_LIBRARIES
    Libraries needed to link to the package library.
  LDAP_VERSION
    Package version, if found.

Cache variables:

  LDAP_INCLUDE_DIR
    Directory containing package library headers.
  LDAP_LIBRARY
    The path to the package library.
  LDAP_LBER_LIBRARY
    The path to the OpenLDAP LBER Lightweight Basic Encoding Rules library, if
    found.
  HAVE_ORALDAP
    Whether the Oracle LDAP library is used.

Hints:

  The LDAP_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  LDAP
  PROPERTIES
    URL "https://www.openldap.org/"
    DESCRIPTION "Lightweight directory access protocol library"
    PURPOSE "https://en.wikipedia.org/wiki/List_of_LDAP_software"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_LDAP QUIET ldap)

find_path(
  LDAP_INCLUDE_DIR
  NAMES ldap.h
  PATHS ${PC_LDAP_INCLUDE_DIRS}
  PATH_SUFFIXES
    # For LDAP on Oracle.
    ldap/public
    # For Oracle Instant Client ZIP install.
    sdk/include
    # TODO: Oracle Instant Client RPM install.
    # /usr/include/oracle/.../client...
  DOC "Directory containing LDAP library headers"
)

if(NOT LDAP_INCLUDE_DIR)
  string(APPEND _reason "ldap.h not found. ")
endif()

find_library(
  LDAP_LIBRARY
  NAMES ldap
  PATHS ${PC_LDAP_LIBRARY_DIRS}
  DOC "The path to the LDAP library"
)

if(LDAP_LIBRARY)
  pkg_check_modules(PC_LDAP_LBER QUIET lber)

  find_library(
    LDAP_LBER_LIBRARY
    NAMES lber
    PATHS ${PC_LDAP_LBER_LIBRARY_DIRS}
    DOC "The path to the OpenLDAP LBER Lightweight Basic Encoding Rules library"
  )
else()
  # Check for Oracle LDAP.
  find_library(
    LDAP_LIBRARY
    NAMES clntsh
    DOC "The path to the Oracle LDAP library"
  )

  if(LDAP_LIBRARY)
    set(HAVE_ORALDAP 1 CACHE INTERNAL "Whether to use Oracle LDAP library")
  endif()
endif()

if(NOT LDAP_LIBRARY)
  string(APPEND _reason "LDAP library not found. ")
endif()

# Get version.
block(PROPAGATE LDAP_VERSION)
  if(LDAP_INCLUDE_DIR AND EXISTS ${LDAP_INCLUDE_DIR}/ldap_features.h)
    file(
      STRINGS
      ${LDAP_INCLUDE_DIR}/ldap_features.h
      results
      REGEX
      "^#[ \t]*define[ \t]+LDAP_VENDOR_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*$"
    )

    unset(LDAP_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+LDAP_VENDOR_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED LDAP_VERSION)
            string(APPEND LDAP_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(LDAP_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

# Sanity check.
if(LDAP_LIBRARY AND LDAP_INCLUDE_DIR)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${LDAP_LIBRARY})
    set(CMAKE_REQUIRED_INCLUDES ${LDAP_INCLUDE_DIR})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(ldap_sasl_bind_s "ldap.h" _ldap_sanity_check)

    # Fallback to deprecated ldap_simple_bind_s().
    if(NOT _ldap_sanity_check)
      unset(_ldap_sanity_check CACHE)
      check_symbol_exists(ldap_simple_bind_s "ldap.h" _ldap_sanity_check)
    endif()
  cmake_pop_check_state()

  if(NOT _ldap_sanity_check)
    string(
      APPEND
      _reason
      "Sanity check failed: ldap_sasl_bind_s() or ldap_simple_bind_s() not "
      "found. "
    )
  endif()
endif()

mark_as_advanced(
  LDAP_INCLUDE_DIR
  LDAP_LBER_LIBRARY
  LDAP_LIBRARY
)

find_package_handle_standard_args(
  LDAP
  REQUIRED_VARS
    LDAP_LIBRARY
    LDAP_INCLUDE_DIR
    _ldap_sanity_check
  VERSION_VAR LDAP_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT LDAP_FOUND)
  return()
endif()

set(LDAP_INCLUDE_DIRS ${LDAP_INCLUDE_DIR})
set(LDAP_LIBRARIES ${LDAP_LIBRARY})
if(LDAP_LBER_LIBRARY)
  list(APPEND LDAP_LIBRARIES ${LDAP_LBER_LIBRARY})
endif()

if(LDAP_LBER_LIBRARY AND NOT TARGET LDAP::LBER)
  add_library(LDAP::LBER UNKNOWN IMPORTED)

  set_target_properties(
    LDAP::LBER
    PROPERTIES
      IMPORTED_LOCATION "${LDAP_LBER_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${LDAP_INCLUDE_DIR}"
  )
endif()

if(NOT TARGET LDAP::LDAP)
  add_library(LDAP::LDAP UNKNOWN IMPORTED)

  set_target_properties(
    LDAP::LDAP
    PROPERTIES
      IMPORTED_LOCATION "${LDAP_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${LDAP_INCLUDE_DIR}"
  )

  if(TARGET LDAP::LBER)
    set_target_properties(
      LDAP::LDAP
      PROPERTIES
        INTERFACE_LINK_LIBRARIES LDAP::LBER)
  endif()
endif()
