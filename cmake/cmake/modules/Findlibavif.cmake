#[=============================================================================[
# Findlibavif

Finds the libavif library:

```cmake
find_package(libavif [<version>] [...])
```

This is a helper in case system doesn't have the library's Config find module.

## Imported targets

This module provides the following imported targets:

* `libavif::libavif` - The package library, if found.

## Result variables

* `libavif_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `libavif_VERSION` - The version of package found.

## Cache variables

* `libavif_INCLUDE_DIR` - Directory containing package library headers.
* `libavif_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libavif)
target_link_libraries(example PRIVATE libavif::libavif)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  libavif
  PROPERTIES
    URL "https://github.com/AOMediaCodec/libavif"
    DESCRIPTION "Library for encoding and decoding .avif files"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_libavif QUIET libavif)
endif()

find_path(
  libavif_INCLUDE_DIR
  NAMES avif/avif.h
  HINTS ${PC_libavif_INCLUDE_DIRS}
  DOC "Directory containing libavif library headers"
)

if(NOT libavif_INCLUDE_DIR)
  string(APPEND _reason "avif/avif.h not found. ")
endif()

find_library(
  libavif_LIBRARY
  NAMES avif
  HINTS ${PC_libavif_LIBRARY_DIRS}
  DOC "The path to the libavif library"
)

if(NOT libavif_LIBRARY)
  string(APPEND _reason "libavif library not found. ")
endif()

block(PROPAGATE libavif_VERSION)
  if(libavif_INCLUDE_DIR)
    file(
      STRINGS
      ${libavif_INCLUDE_DIR}/avif/avif.h
      results
      REGEX
      "^#[ \t]*define[ \t]+AVIF_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[^\n]*$"
    )

    unset(libavif_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+AVIF_VERSION_${item}[ \t]+([0-9]+)[^\n]*$")
          if(DEFINED libavif_VERSION)
            string(APPEND libavif_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(libavif_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(libavif_INCLUDE_DIR libavif_LIBRARY)

find_package_handle_standard_args(
  libavif
  REQUIRED_VARS
    libavif_LIBRARY
    libavif_INCLUDE_DIR
  VERSION_VAR libavif_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT libavif_FOUND)
  return()
endif()

if(NOT TARGET libavif::libavif)
  add_library(libavif::libavif UNKNOWN IMPORTED)

  set_target_properties(
    libavif::libavif
    PROPERTIES
      IMPORTED_LOCATION "${libavif_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${libavif_INCLUDE_DIR}"
  )
endif()
