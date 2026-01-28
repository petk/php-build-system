#[=============================================================================[
# Findcmocka

Finds the cmocka library:

```cmake
find_package(cmocka [<version>] [...])
```

This module checks if cmocka library can be found in *config mode*. If cmocka
installation provides its CMake config file, this module returns the results
without further action. If the upstream config file is not found, this module
falls back to *module mode* and searches standard locations.

## Imported targets

This module provides the following imported targets:

* `cmocka::cmocka` - Target encapsulating the package usage requirements,
  available if package was found.

## Result variables

This module defines the following variables:

* `cmocka_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `cmocka_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `cmocka_INCLUDE_DIR` - Directory containing package library headers. This
  variable is only available when cmocka is found in *module mode*.
* `cmocka_LIBRARY` - The path to the package library. This
  variable is only available when cmocka is found in *module mode*.

# Hints

This module accepts the following variables before calling
`find_package(cmocka)`:

* `cmocka_NO_CMOCKA_CMAKE` - Set this variable to boolean true to disable
  searching for cmocka via *config mode*.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(cmocka)
target_link_libraries(example PRIVATE cmocka::cmocka)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  cmocka
  PROPERTIES
    URL "https://cmocka.org/"
    DESCRIPTION "Unit testing framework for C"
)

# Try config mode.
if(NOT cmocka_NO_CMOCKA_CMAKE)
  find_package(cmocka CONFIG)
  if(cmocka_FOUND AND TARGET cmocka::cmocka)
    find_package_handle_standard_args(cmocka HANDLE_VERSION_RANGE CONFIG_MODE)
    mark_as_advanced(cmocka_DIR)
    return()
  endif()
endif()

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_cmocka QUIET cmocka)
endif()

find_path(
  cmocka_INCLUDE_DIR
  NAMES cmocka.h
  HINTS ${PC_cmocka_INCLUDE_DIRS}
  DOC "Directory containing cmocka library headers"
)
mark_as_advanced(cmocka_INCLUDE_DIR)

if(NOT cmocka_INCLUDE_DIR)
  string(APPEND _reason "<cmocka.h> not found. ")
endif()

find_library(
  cmocka_LIBRARY
  NAMES cmocka
  HINTS ${PC_cmocka_LIBRARY_DIRS}
  DOC "The path to the cmocka library"
)
mark_as_advanced(cmocka_LIBRARY)

if(NOT cmocka_LIBRARY)
  string(APPEND _reason "cmocka library not found. ")
endif()

# Get version.
block(PROPAGATE cmocka_VERSION)
  if(cmocka_INCLUDE_DIR AND EXISTS ${cmocka_INCLUDE_DIR}/cmocka_version.h)
    file(
      STRINGS
      ${cmocka_INCLUDE_DIR}/cmocka_version.h
      results
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+CMOCKA_VERSION_(MAJOR|MINOR|MICRO)[ \t]+[0-9]+[ \t]*$"
    )

    set(cmocka_VERSION "")

    foreach(item MAJOR MINOR MICRO)
      foreach(line ${results})
        if(line MATCHES "^[ \t]*#[ \t]*define[ \t]+CMOCKA_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(cmocka_VERSION)
            string(APPEND cmocka_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(cmocka_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()

  if(
    NOT cmocka_VERSION
    AND PC_cmocka_VERSION
    AND cmocka_INCLUDE_DIR IN_LIST PC_cmocka_INCLUDE_DIRS
  )
    set(cmocka_VERSION ${PC_cmocka_VERSION})
  endif()
endblock()

find_package_handle_standard_args(
  cmocka
  REQUIRED_VARS
    cmocka_LIBRARY
    cmocka_INCLUDE_DIR
  VERSION_VAR cmocka_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT cmocka_FOUND)
  return()
endif()

if(NOT TARGET cmocka::cmocka)
  add_library(cmocka::cmocka UNKNOWN IMPORTED)

  set_target_properties(
    cmocka::cmocka
    PROPERTIES
      IMPORTED_LOCATION "${cmocka_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${cmocka_INCLUDE_DIR}"
  )
endif()
