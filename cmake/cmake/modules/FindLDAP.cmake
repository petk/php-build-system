#[=============================================================================[
Find the LDAP library.

Module defines the following IMPORTED targets:

  LDAP::LDAP
    The LDAP library, if found.

Result variables:

  LDAP_FOUND
    Whether LDAP library is found.
  LDAP_INCLUDE_DIRS
    A list of include directories for using LDAP library.
  LDAP_LIBRARIES
    A list of libraries for using LDAP library.
  LDAP_VERSION
    Version string of found LDAP library.

Cache variables:

  HAVE_ORALDAP
    Whether the Oracle LDAP library is used.

Hints:

  The LDAP_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(LDAP PROPERTIES
  URL "https://www.openldap.org/"
  DESCRIPTION "Lightweight directory access protocol library"
  PURPOSE "https://en.wikipedia.org/wiki/List_of_LDAP_software"
)

set(_reason_failure_message)

find_path(
  LDAP_INCLUDE_DIRS ldap.h
  PATH_SUFFIXES
    # For LDAP on Oracle.
    ldap/public
    # For Oracle Instant Client ZIP install.
    sdk/include
    # TODO: Oracle Instant Client RPM install.
    # /usr/include/oracle/.../client...
)

if(NOT LDAP_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    ldap.h not found."
  )
endif()

find_library(LDAP_LIBRARY NAMES ldap DOC "The LDAP library")

if(LDAP_LIBRARY)
  list(APPEND LDAP_LIBRARIES ${LDAP_LIBRARY})

  find_library(
    LDAP_LBER_LIBRARY NAMES lber
    DOC "The OpenLDAP LBER Lightweight Basic Encoding Rules library"
  )

  if(LDAP_LBER_LIBRARY)
    list(APPEND LDAP_LIBRARIES ${LDAP_LBER_LIBRARY})
  endif()
else()
  # Check for Oracle LDAP.
  find_library(LDAP_CLNTSH_LIBRARY NAMES clntsh DOC "The Oracle LDAP library")

  if(LDAP_CLNTSH_LIBRARY)
    list(APPEND LDAP_LIBRARIES ${LDAP_CLNTSH_LIBRARY})
    set(HAVE_ORALDAP 1 CACHE INTERNAL "Whether to use Oracle LDAP library")
  endif()
endif()

if(NOT LDAP_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    LDAP not found. Please install the LDAP library."
  )
endif()

block(PROPAGATE LDAP_VERSION)
  if(LDAP_INCLUDE_DIRS AND EXISTS "${LDAP_INCLUDE_DIRS}/ldap_features.h")
    file(
      STRINGS
      "${LDAP_INCLUDE_DIRS}/ldap_features.h"
      strings
      REGEX
      "^#[ \t]*define[ \t]+LDAP_VENDOR_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*$"
    )

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${strings})
        if(line MATCHES "^#[ \t]*define[ \t]+LDAP_VENDOR_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(LDAP_VERSION)
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
if(LDAP_LIBRARIES AND LDAP_INCLUDE_DIRS)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${LDAP_LIBRARIES})
    set(CMAKE_REQUIRED_INCLUDES ${LDAP_INCLUDE_DIRS})

    check_symbol_exists(ldap_sasl_bind_s "ldap.h" _ldap_sanity_check)
  cmake_pop_check_state()
endif()

if(NOT _ldap_sanity_check)
  string(
    APPEND _reason_failure_message
    "\n    LDAP sanity check failed, ldap_bind_s() could not be found."
  )
endif()

find_package_handle_standard_args(
  LDAP
  REQUIRED_VARS LDAP_LIBRARIES LDAP_INCLUDE_DIRS _ldap_sanity_check
  VERSION_VAR LDAP_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(LDAP_FOUND AND NOT TARGET LDAP::LDAP)
  add_library(LDAP::LDAP INTERFACE IMPORTED)

  set_target_properties(LDAP::LDAP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${LDAP_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${LDAP_LIBRARIES}"
  )
endif()
