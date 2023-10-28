#[=============================================================================[
Find the systemd library (libsystemd).

Module defines the following IMPORTED targets:

  Systemd::Systemd
    The systemd library, if found.

Result variables:

  Systemd_FOUND
    Set to 1 if systemd library is found.
  Systemd_INCLUDE_DIRS
    A list of include directories for using systemd library.
  Systemd_LIBRARIES
    A list of libraries for using systemd library.
  Systemd_VERSION
    Version string of found systemd library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Systemd PROPERTIES
  URL "https://www.freedesktop.org/wiki/Software/systemd/"
  DESCRIPTION "System and service manager library"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(Systemd_FIND_VERSION)
    set(_pkg_module_spec "libsystemd>=${Systemd_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libsystemd")
  endif()

  pkg_search_module(Systemd QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Systemd
  REQUIRED_VARS Systemd_LIBRARIES
  VERSION_VAR Systemd_VERSION
  REASON_FAILURE_MESSAGE "The systemd not found. Please install systemd library."
)

if(Systemd_FOUND AND NOT TARGET Systemd::Systemd)
  add_library(Systemd::Systemd INTERFACE IMPORTED)

  set_target_properties(Systemd::Systemd PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Systemd_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Systemd_INCLUDE_DIRS}"
  )
endif()
