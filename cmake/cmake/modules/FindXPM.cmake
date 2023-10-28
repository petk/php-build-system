#[=============================================================================[
Find the libXpm library.

Module defines the following IMPORTED targets:

  XPM::XPM
    The libXpm library, if found.

Result variables:

  XPM_FOUND
    Set to 1 if libXpm library is found.
  XPM_INCLUDE_DIRS
    A list of include directories for using libXpm library.
  XPM_LIBRARIES
    A list of libraries for using libXpm.
  XPM_VERSION
    Version string of found libXpm.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(XPM PROPERTIES
  URL "https://gitlab.freedesktop.org/xorg/lib/libxpm"
  DESCRIPTION "X Pixmap Library"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(XPM_FIND_VERSION)
    set(_pkg_module_spec "xpm>=${XPM_FIND_VERSION}")
  else()
    set(_pkg_module_spec "xpm")
  endif()

  pkg_search_module(XPM QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  XPM
  REQUIRED_VARS XPM_LIBRARIES
  VERSION_VAR XPM_VERSION
  REASON_FAILURE_MESSAGE "libXpm not found. Please install libXpm library."
)

if(XPM_FOUND AND NOT TARGET XPM::XPM)
  add_library(XPM::XPM INTERFACE IMPORTED)

  set_target_properties(XPM::XPM PROPERTIES
    INTERFACE_LINK_LIBRARIES "${XPM_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${XPM_INCLUDE_DIRS}"
  )
endif()
