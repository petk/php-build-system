#[=============================================================================[
# FindGD

Finds the GD library:

```cmake
find_package(GD)
```

## Imported targets

This module defines the following imported targets:

* `GD::GD` - The package library, if found.

## Result variables

* `GD_FOUND` - Whether the package has been found.
* `GD_INCLUDE_DIRS` - Include directories needed to use this package.
* `GD_LIBRARIES` - Libraries needed to link to the package library.
* `GD_VERSION` - Package version, if found.

## Cache variables

* `GD_INCLUDE_DIR` - Directory containing package library headers.
* `GD_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(GD)
target_link_libraries(example PRIVATE GD::GD)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  GD
  PROPERTIES
    URL "https://libgd.github.io/"
    DESCRIPTION "Library for dynamic creation of images"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_GD QUIET gdlib)
endif()

find_path(
  GD_INCLUDE_DIR
  NAMES gd.h
  HINTS ${PC_GD_INCLUDE_DIRS}
  DOC "Directory containing GD library headers"
)

if(NOT GD_INCLUDE_DIR)
  string(APPEND _reason "gd.h not found. ")
endif()

find_library(
  GD_LIBRARY
  NAMES gd
  HINTS ${PC_GD_LIBRARY_DIRS}
  DOC "The path to the GD library"
)

if(NOT GD_LIBRARY)
  string(APPEND _reason "GD library (libgd) not found. ")
endif()

# Get version.
block(PROPAGATE GD_VERSION)
  if(GD_INCLUDE_DIR)
    file(
      STRINGS
      ${GD_INCLUDE_DIR}/gd.h
      results
      REGEX
      "^#[ \t]*define[ \t]+GD_(MAJOR|MINOR|RELEASE)_VERSION[ \t]+[0-9]+[ \t]*[^\n]*$"
    )

    unset(GD_VERSION)

    foreach(item MAJOR MINOR RELEASE)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+GD_${item}_VERSION[ \t]+([0-9]+)[ \t]*[^\n]*$")
          if(DEFINED GD_VERSION)
            string(APPEND GD_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(GD_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(GD_INCLUDE_DIR GD_LIBRARY)

find_package_handle_standard_args(
  GD
  REQUIRED_VARS
    GD_LIBRARY
    GD_INCLUDE_DIR
  VERSION_VAR GD_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT GD_FOUND)
  return()
endif()

set(GD_INCLUDE_DIRS ${GD_INCLUDE_DIR})
set(GD_LIBRARIES ${GD_LIBRARY})

if(NOT TARGET GD::GD)
  add_library(GD::GD UNKNOWN IMPORTED)

  set_target_properties(
    GD::GD
    PROPERTIES
      IMPORTED_LOCATION "${GD_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${GD_INCLUDE_DIRS}"
  )
endif()
