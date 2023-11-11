#[=============================================================================[
Find the SELinux library.

Module defines the following IMPORTED targets:

  SELinux::SELinux
    The SELinux library, if found.

Result variables:

  SELinux_FOUND
    Whether SELinux library is found.
  SELinux_INCLUDE_DIRS
    A list of include directories for using SELinux library.
  SELinux_LIBRARIES
    A list of libraries for using SELinux library.
  SELinux_VERSION
    Version string of found SELinux library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(SELinux PROPERTIES
  URL "http://selinuxproject.org/"
  DESCRIPTION "Security Enhanced Linux"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(SELinux_FIND_VERSION)
    set(_pkg_module_spec "libselinux>=${SELinux_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libselinux")
  endif()

  pkg_search_module(SELinux QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  SELinux
  REQUIRED_VARS SELinux_LIBRARIES
  VERSION_VAR SELinux_VERSION
  REASON_FAILURE_MESSAGE "SELinux not found. Please install SELinux library (libselinux)."
)

if(SELinux_FOUND AND NOT TARGET SELinux::SELinux)
  add_library(SELinux::SELinux INTERFACE IMPORTED)

  set_target_properties(SELinux::SELinux PROPERTIES
    INTERFACE_LINK_LIBRARIES "${SELinux_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${SELinux_INCLUDE_DIRS}"
  )
endif()
