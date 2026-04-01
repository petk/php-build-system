#[=============================================================================[
# FindMPIR

Finds the MPIR library with GMP compatibility:

```cmake
find_package(MPIR [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `MPIR::MPIR` - The package library, if found.

## Result variables

This module defines the following variables:

* `MPIR_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `MPIR_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `MPIR_INCLUDE_DIR` - Directory containing package library headers.
* `MPIR_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(MPIR)`:

* `MPIR_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(MPIR)
target_link_libraries(example PRIVATE MPIR::MPIR)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  MPIR
  PROPERTIES
    URL "https://github.com/wbhart/mpir"
    DESCRIPTION "Multiple Precision Integers and Rationals library"
)

set(_reason "")

find_path(
  MPIR_INCLUDE_DIR
  NAMES gmp.h
  DOC "Directory containing MPIR library headers"
)
mark_as_advanced(MPIR_INCLUDE_DIR)

if(NOT MPIR_INCLUDE_DIR)
  string(APPEND _reason "MPIR GMP compatibility header <gmp.h> not found. ")
endif()

block()
  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  if(MPIR_USE_STATIC_LIBS)
    if(WIN32)
      list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()
  endif()

  find_library(
    MPIR_LIBRARY
    NAMES
      mpir
      mpir_a # Winlibs builds it as libmpir_a.lib
    DOC "The path to the MPIR library"
  )
  mark_as_advanced(MPIR_LIBRARY)
endblock()

if(NOT MPIR_LIBRARY)
  string(APPEND _reason "MPIR library not found. ")
endif()

# Get version.
block(PROPAGATE MPIR_VERSION)
  if(EXISTS ${MPIR_INCLUDE_DIR}/gmp.h)
    file(
      STRINGS
      ${MPIR_INCLUDE_DIR}/gmp.h
      results
      REGEX
      "^#[ \t]*define[ \t]+__MPIR_VERSION(_MINOR|_PATCHLEVEL)?[ \t]+[0-9]+[ \t]*$"
    )

    set(MPIR_VERSION "")

    foreach(item VERSION VERSION_MINOR VERSION_PATCHLEVEL)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+__MPIR_${item}[ \t]+([0-9]+)[ \t]*$")
          if(MPIR_VERSION)
            string(APPEND MPIR_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(MPIR_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  MPIR
  REQUIRED_VARS
    MPIR_LIBRARY
    MPIR_INCLUDE_DIR
  VERSION_VAR MPIR_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT MPIR_FOUND)
  return()
endif()

if(NOT TARGET MPIR::MPIR)
  add_library(MPIR::MPIR UNKNOWN IMPORTED)

  set_target_properties(
    MPIR::MPIR
    PROPERTIES
      IMPORTED_LOCATION "${MPIR_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${MPIR_INCLUDE_DIR}"
  )
endif()
