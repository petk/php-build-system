#[=============================================================================[
# FindOniguruma

Finds the Oniguruma library:

```cmake
find_package(Oniguruma [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Oniguruma::Oniguruma` - The package library, if Oniguruma is found.

## Result variables

This module defines the following variables:

* `Oniguruma_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `Oniguruma_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Oniguruma_INCLUDE_DIR` - Directory containing package library headers.
* `Oniguruma_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Oniguruma)
target_link_libraries(example PRIVATE Oniguruma::Oniguruma)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Oniguruma
  PROPERTIES
    URL "https://github.com/kkos/oniguruma"
    DESCRIPTION "Regular expression library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_Oniguruma QUIET oniguruma)
endif()

find_path(
  Oniguruma_INCLUDE_DIR
  NAMES oniguruma.h
  HINTS ${PC_Oniguruma_INCLUDE_DIRS}
  DOC "Directory containing Oniguruma library headers"
)

if(NOT Oniguruma_INCLUDE_DIR)
  string(APPEND _reason "oniguruma.h not found. ")
endif()

find_library(
  Oniguruma_LIBRARY
  NAMES onig
  HINTS ${PC_Oniguruma_LIBRARY_DIRS}
  DOC "The path to the Oniguruma library"
)

if(NOT Oniguruma_LIBRARY)
  string(APPEND _reason "Oniguruma library (libonig) not found. ")
endif()

block(PROPAGATE Oniguruma_VERSION)
  if(Oniguruma_INCLUDE_DIR)
    file(
      STRINGS
      ${Oniguruma_INCLUDE_DIR}/oniguruma.h
      results
      REGEX
      "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_(MAJOR|MINOR|TEENY)[ \t]+[0-9]+[ \t]*$"
    )

    unset(Oniguruma_VERSION)

    foreach(item MAJOR MINOR TEENY)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED Oniguruma_VERSION)
            string(APPEND Oniguruma_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Oniguruma_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(Oniguruma_INCLUDE_DIR Oniguruma_LIBRARY)

find_package_handle_standard_args(
  Oniguruma
  REQUIRED_VARS
    Oniguruma_LIBRARY
    Oniguruma_INCLUDE_DIR
  VERSION_VAR Oniguruma_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Oniguruma_FOUND)
  return()
endif()

if(NOT TARGET Oniguruma::Oniguruma)
  add_library(Oniguruma::Oniguruma UNKNOWN IMPORTED)

  set_target_properties(
    Oniguruma::Oniguruma
    PROPERTIES
      IMPORTED_LOCATION "${Oniguruma_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Oniguruma_INCLUDE_DIR}"
  )
endif()
