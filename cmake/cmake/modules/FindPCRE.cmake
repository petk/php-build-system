#[=============================================================================[
# FindPCRE

Finds the PCRE library:

```cmake
find_package(PCRE [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `PCRE::PCRE` - The package library, if found.

## Result variables

* `PCRE_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `PCRE_VERSION` - The version of package found.

## Cache variables

* `PCRE_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(PCRE)
target_link_libraries(example PRIVATE PCRE::PCRE)
```
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

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
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

if(NOT PCRE_LIBRARY)
  string(APPEND _reason "PCRE library not found. ")
endif()

block(PROPAGATE PCRE_VERSION)
  if(PCRE_INCLUDE_DIR)
    file(
      STRINGS
      ${PCRE_INCLUDE_DIR}/pcre2.h
      results
      REGEX "^#[ \t]*define[ \t]+PCRE2_(MAJOR|MINOR)[ \t]+[0-9]+[^\n]*$"
    )

    unset(PCRE_VERSION)

    foreach(item MAJOR MINOR)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+PCRE2_${item}[ \t]+([0-9]+)[^\n]*$")
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
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT PCRE_FOUND)
  return()
endif()

if(NOT TARGET PCRE::PCRE)
  add_library(PCRE::PCRE UNKNOWN IMPORTED)

  set_target_properties(
    PCRE::PCRE
    PROPERTIES
      IMPORTED_LOCATION "${PCRE_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${PCRE_INCLUDE_DIR}"
  )
endif()
