#[=============================================================================[
# FindFFI

Finds the FFI library:

```cmake
find_package(FFI)
```

## Imported targets

This module defines the following imported targets:

* `FFI::FFI` - The package library, if found.

## Result variables

* `FFI_FOUND` - Boolean indicating whether the package is found.
* `FFI_VERSION` - The version of package found.

## Cache variables

* `FFI_INCLUDE_DIR` - Directory containing package library headers.
* `FFI_LIBRARY` - The path to the package library.

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

if(NOT FFI_INCLUDE_DIR)
  string(APPEND _reason "ffi.h not found. ")
endif()

find_library(
  FFI_LIBRARY
  NAMES ffi
  HINTS ${PC_FFI_LIBRARY_DIRS}
  DOC "The path to the FFI library"
)

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

mark_as_advanced(FFI_INCLUDE_DIR FFI_LIBRARY)

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
