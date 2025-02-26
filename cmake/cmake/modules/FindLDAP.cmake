#[=============================================================================[
# FindLDAP

Find the LDAP library.

## Components

* `LDAP` - the main LDAP library
* `LBER` - the OpenLDAP LBER (Lightweight Basic Encoding Rules) library

Module defines the following `IMPORTED` target(s):

* `LDAP::LDAP` - The LDAP library, if found.
* `LDAP::LBER` - OpenLDAP LBER Lightweight Basic Encoding Rules library, if
  found.

## Result variables

* `LDAP_FOUND` - Whether the package has been found.
* `LDAP_INCLUDE_DIRS` - Include directories needed to use this package.
* `LDAP_LIBRARIES` - Libraries needed to link to the package library.
* `LDAP_VERSION` - Package version, if found.

## Cache variables

* `LDAP_INCLUDE_DIR` - Directory containing package library headers.
* `LDAP_LIBRARY` - The path to the package library.
* `LDAP_LBER_INCLUDE_DIR` - The path to the OpenLDAP LBER library headers, if
  found.
* `LDAP_LBER_LIBRARY` - The path to the OpenLDAP LBER library, if found.

## Usage

When OpenLDAP is found, both LDAP and LBER libraries are linked in for
convenience.

```cmake
# CMakeLists.txt

find_package(LDAP)
target_link_library(some_project_target PRIVATE LDAP::LDAP)
```

When working with specific components, LDAP and LBER are linked separately.

```cmake
find_package(LDAP COMPONENTS LDAP LBER)
target_link_library(some_project_target PRIVATE LDAP::LDAP LDAP::LBER)
```

To use only the LBER component:

```cmake
find_package(LDAP COMPONENTS LBER)
target_link_library(some_project_target PRIVATE LDAP::LBER)
```
#]=============================================================================]

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

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_LDAP QUIET ldap)
endif()

find_path(
  LDAP_INCLUDE_DIR
  NAMES ldap.h
  HINTS ${PC_LDAP_INCLUDE_DIRS}
  DOC "Directory containing LDAP library headers"
)

if(NOT LDAP_INCLUDE_DIR)
  string(APPEND _reason "ldap.h not found. ")
endif()

find_library(
  LDAP_LIBRARY
  NAMES ldap
  HINTS ${PC_LDAP_LIBRARY_DIRS}
  DOC "The path to the LDAP library"
)

if(NOT LDAP_LIBRARY)
  string(APPEND _reason "LDAP library not found. ")
endif()

if(LDAP_LIBRARY AND LDAP_INCLUDE_DIR)
  set(LDAP_LDAP_FOUND TRUE)
endif()

if(LDAP_LIBRARY)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_LDAP_LBER QUIET lber)
  endif()

  find_path(
    LDAP_LBER_INCLUDE_DIR
    NAMES lber.h
    HINTS ${PC_LDAP_LBER_INCLUDE_DIRS}
    DOC "Directory containing LBER library headers"
  )

  find_library(
    LDAP_LBER_LIBRARY
    NAMES lber
    HINTS ${PC_LDAP_LBER_LIBRARY_DIRS}
    DOC "The path to the OpenLDAP LBER Lightweight Basic Encoding Rules library"
  )
endif()

if(LDAP_LBER_INCLUDE_DIR AND LDAP_LBER_LIBRARY)
  set(LDAP_LBER_FOUND TRUE)
elseif("LBER" IN_LIST LDAP_FIND_COMPONENTS)
  string(APPEND _reason "LDAP LBER library (lber) not found. ")
endif()

# Get version.
block(PROPAGATE LDAP_VERSION)
  if(EXISTS ${LDAP_INCLUDE_DIR}/ldap_features.h)
    file(
      STRINGS
      ${LDAP_INCLUDE_DIR}/ldap_features.h
      results
      REGEX
      "^#[ \t]*define[ \t]+LDAP_VENDOR_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*$"
    )

    set(LDAP_VERSION "")

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
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

mark_as_advanced(
  LDAP_INCLUDE_DIR
  LDAP_LIBRARY
  LDAP_LBER_INCLUDE_DIR
  LDAP_LBER_LIBRARY
)

find_package_handle_standard_args(
  LDAP
  REQUIRED_VARS
    LDAP_LIBRARY
    LDAP_INCLUDE_DIR
  VERSION_VAR LDAP_VERSION
  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT LDAP_FOUND)
  return()
endif()

set(LDAP_INCLUDE_DIRS ${LDAP_INCLUDE_DIR})
set(LDAP_LIBRARIES ${LDAP_LIBRARY})
set(LDAP_LBER_INCLUDE_DIRS ${LDAP_LBER_INCLUDE_DIR})
set(LDAP_LBER_LIBRARIES ${LDAP_LBER_LIBRARY})

if(LDAP_LBER_LIBRARY AND NOT TARGET LDAP::LBER)
  if(IS_ABSOLUTE "${LDAP_LBER_LIBRARY}")
    add_library(LDAP::LBER UNKNOWN IMPORTED)
    set_target_properties(
      LDAP::LBER
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${LDAP_LBER_LIBRARY}"
    )
  else()
    add_library(LDAP::LBER INTERFACE IMPORTED)
    set_target_properties(
      LDAP::LBER
      PROPERTIES
        IMPORTED_LIBNAME "${LDAP_LBER_LIBRARY}"
    )
  endif()

  set_target_properties(
    LDAP::LBER
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${LDAP_LBER_INCLUDE_DIRS}"
  )
endif()

if(NOT TARGET LDAP::LDAP)
  if(IS_ABSOLUTE "${LDAP_LIBRARY}")
    add_library(LDAP::LDAP UNKNOWN IMPORTED)
    set_target_properties(
      LDAP::LDAP
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${LDAP_LIBRARY}"
    )
  else()
    add_library(LDAP::LDAP INTERFACE IMPORTED)
    set_target_properties(
      LDAP::LDAP
      PROPERTIES
        IMPORTED_LIBNAME "${LDAP_LIBRARY}"
    )
  endif()

  set_target_properties(
    LDAP::LDAP
    PROPERTIES
      IMPORTED_LOCATION "${LDAP_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${LDAP_INCLUDE_DIRS}"
  )

  if(NOT LDAP_FIND_COMPONENTS AND TARGET LDAP::LBER)
    set_target_properties(
      LDAP::LDAP
      PROPERTIES
        INTERFACE_LINK_LIBRARIES LDAP::LBER
    )
  endif()
endif()
