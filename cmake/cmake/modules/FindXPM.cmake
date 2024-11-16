#[=============================================================================[
Find the libXpm library.

Module defines the following `IMPORTED` target(s):

* `XPM::XPM` - The libXpm library, if found.

Result variables:

* `XPM_FOUND` - Whether the package has been found.
* `XPM_INCLUDE_DIRS` - Include directories needed to use this package.
* `XPM_LIBRARIES` - Libraries needed to link to the package library.
* `XPM_VERSION` - Package version, if found.

Cache variables:

* `XPM_INCLUDE_DIR` - Directory containing package library headers.
* `XPM_LIBRARY` - The path to the package library.

Hints:

The `XPM_ROOT` variable adds custom search path.
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

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
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

set(XPM_INCLUDE_DIRS ${XPM_INCLUDE_DIR})
set(XPM_LIBRARIES ${XPM_LIBRARY})

if(NOT TARGET XPM::XPM)
  add_library(XPM::XPM UNKNOWN IMPORTED)

  set_target_properties(
    XPM::XPM
    PROPERTIES
      IMPORTED_LOCATION "${XPM_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${XPM_INCLUDE_DIRS}"
  )
endif()
