#[=============================================================================[
# FindXPM

Finds the libXpm library:

```cmake
find_package(XPM [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `XPM::XPM` - The libXpm library, if found.

## Result variables

This module defines the following variables:

* `XPM_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `XPM_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `XPM_INCLUDE_DIR` - Directory containing package library headers.
* `XPM_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(XPM)
target_link_libraries(example PRIVATE XPM::XPM)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  XPM
  PROPERTIES
    URL "https://gitlab.freedesktop.org/xorg/lib/libxpm"
    DESCRIPTION "X Pixmap Library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_XPM QUIET xpm)
endif()

find_path(
  XPM_INCLUDE_DIR
  NAMES X11/xpm.h
  HINTS ${PC_XPM_INCLUDE_DIRS}
  DOC "Directory containing XPM library headers"
)

if(NOT XPM_INCLUDE_DIR)
  string(APPEND _reason "X11/xpm.h not found. ")
endif()

find_library(
  XPM_LIBRARY
  NAMES Xpm
  HINTS ${PC_XPM_LIBRARY_DIRS}
  DOC "The path to the XPM library"
)

if(NOT XPM_LIBRARY)
  string(APPEND _reason "libXpm library not found. ")
endif()

# libXpm headers don't provide version. Try pkg-config.
if(PC_XPM_VERSION AND XPM_INCLUDE_DIR IN_LIST PC_XPM_INCLUDE_DIRS)
  set(XPM_VERSION ${PC_XPM_VERSION})
endif()

mark_as_advanced(XPM_INCLUDE_DIR XPM_LIBRARY)

find_package_handle_standard_args(
  XPM
  REQUIRED_VARS
    XPM_LIBRARY
    XPM_INCLUDE_DIR
  VERSION_VAR XPM_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT XPM_FOUND)
  return()
endif()

if(NOT TARGET XPM::XPM)
  add_library(XPM::XPM UNKNOWN IMPORTED)

  set_target_properties(
    XPM::XPM
    PROPERTIES
      IMPORTED_LOCATION "${XPM_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${XPM_INCLUDE_DIR}"
  )
endif()
