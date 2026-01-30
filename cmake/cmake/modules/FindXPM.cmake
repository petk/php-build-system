#[=============================================================================[
# FindXPM

Finds the libXpm library:

```cmake
find_package(XPM [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `XPM::XPM` - Target encapsulating the libXpm library usage requirements,
  available only if libXpm was found.

## Result variables

This module defines the following variables:

* `XPM_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `XPM_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `XPM_INCLUDE_DIR` - Directory containing package library headers.
* `XPM_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(XPM)`:

* `XPM_USE_STATIC_LIBS` - Set this variable to boolean true to search for static
  libraries.

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
mark_as_advanced(XPM_INCLUDE_DIR)

if(NOT XPM_INCLUDE_DIR)
  string(APPEND _reason "<X11/xpm.h> not found. ")
endif()

block()
  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  if(XPM_USE_STATIC_LIBS)
    if(WIN32)
      list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()
  endif()

  find_library(
    XPM_LIBRARY
    NAMES
      Xpm
      Xpm_a # Winlibs builds it as libXpm_a.lib
    NAMES_PER_DIR
    HINTS ${PC_XPM_LIBRARY_DIRS}
    DOC "The path to the XPM library"
  )
  mark_as_advanced(XPM_LIBRARY)
endblock()

if(NOT XPM_LIBRARY)
  string(APPEND _reason "libXpm library not found. ")
endif()

# libXpm headers don't provide version. Try pkg-config.
if(PC_XPM_VERSION AND XPM_INCLUDE_DIR IN_LIST PC_XPM_INCLUDE_DIRS)
  set(XPM_VERSION ${PC_XPM_VERSION})
endif()

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

  if(XPM_USE_STATIC_LIBS)
    # TODO: X11 libraries are linked as shared but should be linked statically.
    find_package(X11 QUIET)

    if(TARGET X11::X11)
      set_target_properties(
        XPM::XPM
        PROPERTIES
          INTERFACE_LINK_LIBRARIES X11::X11
      )
    endif()
  endif()
endif()
