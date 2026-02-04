#[=============================================================================[
# FindPCRE2

Finds the PCRE library:

```cmake
find_package(PCRE2 [<version>] [...])
```

This module checks if PCRE library can be found in *config mode*. If PCRE
installation provides its CMake config file, this module returns the results
without further action. If the upstream config file is not found, this module
falls back to *module mode* and searches standard locations.

## Imported targets

This module provides the following imported targets:

* `PCRE2::8BIT` - The package library, if found.

## Result variables

This module defines the following variables:

* `PCRE2_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `PCRE2_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `PCRE2_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE2_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(PCRE2)`:

* `PCRE2_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

* `PCRE2_NO_PCRE2_CMAKE` - Set this variable to boolean true to disable
  searching for PCRE via *config mode*.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(PCRE2)
target_link_libraries(example PRIVATE PCRE2::8BIT)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  PCRE2
  PROPERTIES
    URL "https://www.pcre.org/"
    DESCRIPTION "Perl compatible regular expressions library"
)

set(_reason "")

# Try config mode.
if(NOT PCRE2_NO_PCRE2_CMAKE)
  find_package(PCRE2 CONFIG)
  if(PCRE2_FOUND AND TARGET PCRE2::8BIT)
    find_package_handle_standard_args(PCRE2 HANDLE_VERSION_RANGE CONFIG_MODE)
    mark_as_advanced(PCRE2_DIR)
    return()
  endif()
endif()

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_PCRE2 QUIET libpcre2-8)
endif()

find_path(
  PCRE2_INCLUDE_DIR
  NAMES pcre2.h
  HINTS ${PC_PCRE2_INCLUDE_DIRS}
  DOC "Directory containing PCRE library headers"
)
mark_as_advanced(PCRE2_INCLUDE_DIR)

if(NOT PCRE2_INCLUDE_DIR)
  string(APPEND _reason "pcre2.h not found. ")
endif()

block()
  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  if(PCRE2_USE_STATIC_LIBS)
    if(WIN32)
      list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()
  endif()

  find_library(
    PCRE2_LIBRARY
    NAMES pcre2-8
    HINTS ${PC_PCRE2_LIBRARY_DIRS}
    DOC "The path to the PCRE library"
  )
  mark_as_advanced(PCRE2_LIBRARY)
endblock()

if(NOT PCRE2_LIBRARY)
  string(APPEND _reason "PCRE library not found. ")
endif()

block(PROPAGATE PCRE2_VERSION)
  if(PCRE2_INCLUDE_DIR)
    file(
      STRINGS
      ${PCRE2_INCLUDE_DIR}/pcre2.h
      results
      REGEX "^#[ \t]*define[ \t]+PCRE2_(MAJOR|MINOR)[ \t]+[0-9]+[^\n]*$"
    )

    unset(PCRE2_VERSION)

    foreach(item MAJOR MINOR)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+PCRE2_${item}[ \t]+([0-9]+)[^\n]*$")
          if(DEFINED PCRE2_VERSION)
            string(APPEND PCRE2_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(PCRE2_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  PCRE2
  REQUIRED_VARS
    PCRE2_LIBRARY
    PCRE2_INCLUDE_DIR
  VERSION_VAR PCRE2_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT PCRE2_FOUND)
  return()
endif()

if(NOT TARGET PCRE2::8BIT)
  add_library(PCRE2::8BIT UNKNOWN IMPORTED)

  set_target_properties(
    PCRE2::8BIT
    PROPERTIES
      IMPORTED_LOCATION "${PCRE2_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${PCRE2_INCLUDE_DIR}"
  )

  if(PCRE2_USE_STATIC_LIBS AND WIN32)
    set_property(
      TARGET PCRE2::8BIT
      APPEND
      PROPERTY INTERFACE_COMPILE_DEFINITIONS "PCRE2_STATIC"
    )
  endif()
endif()
