#[=============================================================================[
Find the libXpm library.

Module defines the following IMPORTED targets:

  XPM::XPM
    The libXpm library, if found.

Result variables:

  XPM_FOUND
    Whether libXpm library is found.
  XPM_INCLUDE_DIRS
    A list of include directories for using libXpm library.
  XPM_LIBRARIES
    A list of libraries for using libXpm.

Hints:

  The XPM_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(XPM PROPERTIES
  URL "https://gitlab.freedesktop.org/xorg/lib/libxpm"
  DESCRIPTION "X Pixmap Library"
)

set(_reason_failure_message)

find_path(XPM_INCLUDE_DIRS X11/xpm.h DOC "XPM include directories")

if(NOT XPM_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    The X11/xpm.h could not be found."
  )
endif()

find_library(XPM_LIBRARIES NAMES Xpm DOC "XPM library")

if(NOT XPM_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    XPM library not found. Please install libXpm library."
  )
endif()

find_package_handle_standard_args(
  XPM
  REQUIRED_VARS XPM_LIBRARIES XPM_INCLUDE_DIRS
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(XPM_FOUND AND NOT TARGET XPM::XPM)
  add_library(XPM::XPM INTERFACE IMPORTED)

  set_target_properties(XPM::XPM PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${XPM_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${XPM_LIBRARIES}"
  )
endif()
