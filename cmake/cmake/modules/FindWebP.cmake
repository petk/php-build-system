#[=============================================================================[
# FindWebP

Finds the libwebp library:

```cmake
find_package(WebP)
```

## Imported targets

This module defines the following imported targets:

* `WebP::WebP` - The package library, if found.

## Result variables

* `WebP_FOUND` - Whether the package has been found.
* `WebP_INCLUDE_DIRS` - Include directories needed to use this package.
* `WebP_LIBRARIES` - Libraries needed to link to the package library.
* `WebP_VERSION` - Package version, if found.

## Cache variables

* `WebP_INCLUDE_DIR` - Directory containing package library headers.
* `WebP_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(WebP)
target_link_libraries(example PRIVATE WebP::WebP)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  WebP
  PROPERTIES
    URL "https://developers.google.com/speed/webp/"
    DESCRIPTION "Library for the WebP graphics format"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_WebP QUIET libwebp)
endif()

find_path(
  WebP_INCLUDE_DIR
  NAMES webp/decode.h
  HINTS ${PC_WebP_INCLUDE_DIRS}
  DOC "Directory containing libwebp library headers"
)

if(NOT WebP_INCLUDE_DIR)
  string(APPEND _reason "webp/decode.h not found. ")
endif()

find_library(
  WebP_LIBRARY
  NAMES webp
  HINTS ${PC_WebP_LIBRARY_DIRS}
  DOC "The path to the libwebp library"
)

if(NOT WebP_LIBRARY)
  string(APPEND _reason "WebP library not found. ")
endif()

# WebP headers don't provide version. Try pkg-config.
if(PC_WebP_VERSION AND WebP_INCLUDE_DIR IN_LIST PC_WebP_INCLUDE_DIRS)
  set(WebP_VERSION ${PC_WebP_VERSION})
endif()

mark_as_advanced(WebP_INCLUDE_DIR WebP_LIBRARY)

find_package_handle_standard_args(
  WebP
  REQUIRED_VARS
    WebP_LIBRARY
    WebP_INCLUDE_DIR
  VERSION_VAR WebP_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT WebP_FOUND)
  return()
endif()

set(WebP_INCLUDE_DIRS ${WebP_INCLUDE_DIR})
set(WebP_LIBRARIES ${WebP_LIBRARY})

if(NOT TARGET WebP::WebP)
  add_library(WebP::WebP UNKNOWN IMPORTED)

  set_target_properties(
    WebP::WebP
    PROPERTIES
      IMPORTED_LOCATION "${WebP_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIRS}"
  )
endif()
