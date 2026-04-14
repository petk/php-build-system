#[=============================================================================[
# FindLDAP

Finds the LDAP library:

```cmake
find_package(LDAP [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  LDAP
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `LDAP` - Finds the main LDAP library.
* `LBER` - Finds the OpenLDAP LBER (Lightweight Basic Encoding Rules) library.

If no components are specified, by default, the `LDAP` is searched as requied
component and `LBER` as optional component.

## Imported targets

This module provides the following imported targets:

* `LDAP::LDAP` - Target encapsulating the LDAP library usage requirements,
  available if `LDAP` component was found. If also `LBER` component was found,
  the `LDAP::LBER` imported target is also linked in this target for simplicity.
* `LDAP::LBER` - Target encapsulating the OpenLDAP LBER Lightweight Basic
  Encoding Rules library, if LBER library was found.

## Result variables

This module defines the following variables:

* `LDAP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `LDAP_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `LDAP_INCLUDE_DIR` - Directory containing package library headers.
* `LDAP_LIBRARY` - The path to the package library.
* `LDAP_LBER_INCLUDE_DIR` - The path to the OpenLDAP LBER library headers, if
  found.
* `LDAP_LBER_LIBRARY` - The path to the OpenLDAP LBER library, if found.

## Hints

This module accepts the following variables before calling `find_package()`:

* `LDAP_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Finding OpenLDAP and linking both LDAP and LBER libraries:

```cmake
# CMakeLists.txt

find_package(LDAP)
target_link_library(example PRIVATE LDAP::LDAP)
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

block(PROPAGATE LDAP_FOUND LDAP_VERSION)
  set(reason "")
  set(required_vars "")

  # Set default components.
  if(NOT LDAP_FIND_COMPONENTS)
    set(LDAP_FIND_COMPONENTS LDAP LBER)
    set(LDAP_FIND_REQUIRED_LDAP TRUE)
    set(LDAP_FIND_REQUIRED_LBER FALSE)
  endif()

  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  if(LDAP_USE_STATIC_LIBS)
    if(WIN32)
      list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()
  endif()

  if("LDAP" IN_LIST LDAP_FIND_COMPONENTS)
    if(LDAP_FIND_REQUIRED_LDAP)
      list(APPEND required_vars LDAP_LIBRARY LDAP_INCLUDE_DIR)
    endif()

    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
      pkg_check_modules(PC_LDAP QUIET ldap)
    endif()

    find_path(
      LDAP_INCLUDE_DIR
      NAMES ldap.h
      HINTS ${PC_LDAP_INCLUDE_DIRS}
      DOC "Directory containing LDAP library headers"
    )
    mark_as_advanced(LDAP_INCLUDE_DIR)

    if(NOT LDAP_INCLUDE_DIR)
      string(APPEND reason "<ldap.h> not found. ")
    endif()

    find_library(
      LDAP_LIBRARY
      NAMES ldap
      HINTS ${PC_LDAP_LIBRARY_DIRS}
      DOC "The path to the LDAP library"
    )
    mark_as_advanced(LDAP_LIBRARY)

    if(NOT LDAP_LIBRARY)
      string(APPEND reason "LDAP library not found. ")
    endif()

    if(LDAP_LIBRARY AND LDAP_INCLUDE_DIR)
      set(LDAP_LDAP_FOUND TRUE)
    else()
      set(LDAP_LDAP_FOUND FALSE)
    endif()
  endif()

  if("LBER" IN_LIST LDAP_FIND_COMPONENTS)
    if(LDAP_FIND_REQUIRED_LBER)
      list(APPEND required_vars LDAP_LBER_LIBRARY LDAP_LBER_INCLUDE_DIR)
    endif()

    if(PkgConfig_FOUND)
      pkg_check_modules(PC_LDAP_LBER QUIET lber)
    endif()

    find_path(
      LDAP_LBER_INCLUDE_DIR
      NAMES lber.h
      HINTS ${PC_LDAP_LBER_INCLUDE_DIRS}
      DOC "Directory containing LBER library headers"
    )
    mark_as_advanced(LDAP_LBER_INCLUDE_DIR)

    if(NOT LDAP_LBER_INCLUDE_DIR)
      string(APPEND reason "<lber.h> not found. ")
    endif()

    find_library(
      LDAP_LBER_LIBRARY
      NAMES lber
      HINTS ${PC_LDAP_LBER_LIBRARY_DIRS}
      DOC "The path to the OpenLDAP LBER Lightweight Basic Encoding Rules library"
    )
    mark_as_advanced(LDAP_LBER_LIBRARY)

    if(NOT LDAP_LBER_LIBRARY)
      string(APPEND reason "LDAP LBER library not found. ")
    endif()

    if(LDAP_LBER_INCLUDE_DIR AND LDAP_LBER_LIBRARY)
      set(LDAP_LBER_FOUND TRUE)
    else()
      set(LDAP_LBER_FOUND FALSE)
    endif()
  endif()

  ##############################################################################
  # Get version.
  ##############################################################################

  if(EXISTS ${LDAP_INCLUDE_DIR}/ldap_features.h)
    set(include_dir "${LDAP_INCLUDE_DIR}")
  elseif(EXISTS ${LDAP_LBER_INCLUDE_DIR}/ldap_features.h)
    set(include_dir ${LDAP_LBER_INCLUDE_DIR})
  else()
    set(include_dir "")
  endif()

  if(include_dir)
    file(
      STRINGS
      ${include_dir}/ldap_features.h
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

  ##############################################################################

  find_package_handle_standard_args(
    LDAP
    REQUIRED_VARS ${required_vars}
    VERSION_VAR LDAP_VERSION
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
    REASON_FAILURE_MESSAGE "${reason}"
  )

  if(NOT LDAP_FOUND)
    return()
  endif()

  ##############################################################################
  # Create imported targets.
  ##############################################################################

  if(
    "LBER" IN_LIST LDAP_FIND_COMPONENTS
    AND LDAP_LBER_FOUND
    AND NOT TARGET LDAP::LBER
  )
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
        INTERFACE_INCLUDE_DIRECTORIES "${LDAP_LBER_INCLUDE_DIR}"
    )
  endif()

  if(
    "LDAP" IN_LIST LDAP_FIND_COMPONENTS
    AND LDAP_LDAP_FOUND
    AND NOT TARGET LDAP::LDAP
  )
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
        INTERFACE_INCLUDE_DIRECTORIES "${LDAP_INCLUDE_DIR}"
    )

    if(TARGET LDAP::LBER)
      set_target_properties(
        LDAP::LDAP
        PROPERTIES
          INTERFACE_LINK_LIBRARIES LDAP::LBER
      )
    endif()
  endif()
endblock()
