#[=============================================================================[
# FindGMP

Finds the GMP library:

```cmake
find_package(GMP [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `GMP::GMP` - The package library, if found.

## Result variables

* `GMP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `GMP_VERSION` - The version of package found.

## Cache variables

* `GMP_INCLUDE_DIR` - Directory containing package library headers.
* `GMP_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(GMP)
target_link_libraries(example PRIVATE GMP::GMP)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  GMP
  PROPERTIES
    URL "https://gmplib.org/"
    DESCRIPTION "GNU Multiple Precision Arithmetic Library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_GMP QUIET gmp)
endif()

find_path(
  GMP_INCLUDE_DIR
  NAMES gmp.h
  HINTS ${PC_GMP_INCLUDE_DIRS}
  DOC "Directory containing GMP library headers"
)

if(NOT GMP_INCLUDE_DIR)
  string(APPEND _reason "gmp.h not found. ")
endif()

find_library(
  GMP_LIBRARY
  NAMES gmp
  HINTS ${PC_GMP_LIBRARY_DIRS}
  DOC "The path to the GMP library"
)

if(NOT GMP_LIBRARY)
  string(APPEND _reason "GMP library not found. ")
endif()

# Get version.
block(PROPAGATE GMP_VERSION)
  if(GMP_INCLUDE_DIR)
    file(
      STRINGS
      ${GMP_INCLUDE_DIR}/gmp.h
      results
      REGEX
      "^#[ \t]*define[ \t]+__GNU_MP_VERSION(_MINOR|_PATCHLEVEL)?[ \t]+[0-9]+[ \t]*$"
    )

    set(GMP_VERSION "")

    foreach(item VERSION VERSION_MINOR VERSION_PATCHLEVEL)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+__GNU_MP_${item}[ \t]+([0-9]+)[ \t]*$")
          if(GMP_VERSION)
            string(APPEND GMP_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(GMP_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(GMP_LIBRARY GMP_INCLUDE_DIR)

find_package_handle_standard_args(
  GMP
  REQUIRED_VARS
    GMP_LIBRARY
    GMP_INCLUDE_DIR
  VERSION_VAR GMP_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT GMP_FOUND)
  return()
endif()

if(NOT TARGET GMP::GMP)
  add_library(GMP::GMP UNKNOWN IMPORTED)

  set_target_properties(
    GMP::GMP
    PROPERTIES
      IMPORTED_LOCATION "${GMP_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIR}"
  )
endif()
