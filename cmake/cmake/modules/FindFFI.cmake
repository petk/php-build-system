#[=============================================================================[
# FindFFI

Finds the FFI library:

```cmake
find_package(FFI [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `FFI::FFI` - Target encapsulating the FFI library usage requirements,
  available only if FFI was found.

## Result variables

This module defines the following variables:

* `FFI_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `FFI_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `FFI_INCLUDE_DIR` - Directory containing package library headers.
* `FFI_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(FFI)`:

* `FFI_USE_STATIC_LIBS` - Set this variable to boolean true to search for static
  libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(FFI)
target_link_libraries(example PRIVATE FFI::FFI)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  FFI
  PROPERTIES
    URL "https://sourceware.org/libffi/"
    DESCRIPTION "Foreign Function Interface library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_FFI QUIET libffi)
endif()

find_path(
  FFI_INCLUDE_DIR
  NAMES ffi.h
  HINTS ${PC_FFI_INCLUDE_DIRS}
  DOC "Directory containing FFI library headers"
)
mark_as_advanced(FFI_INCLUDE_DIR)

if(NOT FFI_INCLUDE_DIR)
  string(APPEND _reason "ffi.h not found. ")
endif()

block()
  set(names "")

  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  if(FFI_USE_STATIC_LIBS)
    if(WIN32)
      list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()

    # Name of the static library with PIC enabled on Debian-based distributions.
    set(names ffi_pic)
  endif()

  find_library(
    FFI_LIBRARY
    NAMES
      ${names}
      ffi
    NAMES_PER_DIR
    HINTS ${PC_FFI_LIBRARY_DIRS}
    DOC "The path to the FFI library"
  )
  mark_as_advanced(FFI_LIBRARY)
endblock()

if(NOT FFI_LIBRARY)
  string(APPEND _reason "FFI library (libffi) not found. ")
endif()

block(PROPAGATE FFI_VERSION)
  if(FFI_INCLUDE_DIR)
    set(regex "^[ \t]*libffi[ \t]+([0-9.]+)[ \t]*$")
    file(STRINGS ${FFI_INCLUDE_DIR}/ffi.h result REGEX "${regex}" LIMIT_COUNT 1)

    if(result MATCHES "${regex}")
      set(FFI_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT FFI_VERSION
    AND PC_FFI_VERSION
    AND FFI_INCLUDE_DIR IN_LIST PC_FFI_INCLUDE_DIRS
  )
    set(FFI_VERSION ${PC_FFI_VERSION})
  endif()
endblock()

find_package_handle_standard_args(
  FFI
  REQUIRED_VARS
    FFI_LIBRARY
    FFI_INCLUDE_DIR
  VERSION_VAR FFI_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT FFI_FOUND)
  return()
endif()

if(NOT TARGET FFI::FFI)
  add_library(FFI::FFI UNKNOWN IMPORTED)

  set_target_properties(
    FFI::FFI
    PROPERTIES
      IMPORTED_LOCATION "${FFI_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFI_INCLUDE_DIR}"
  )
endif()
