#[=============================================================================[
CMake module to find and use the SELinux library.
http://selinuxproject.org/

If SELinux library is found, the following variables are set:

SELINUX_FOUND
  Set to 1 if SELinux library is found.
SELINUX_LIBRARIES
  A list of libraries for using SELinux library.
SELINUX_INCLUDE_DIRS
  A list of include directories for using SELinux library.
SELINUX_VERSION
  Version string of found SELinux library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(SELINUX_FIND_VERSION)
    set(_pkg_module_spec "libselinux>=${SELINUX_FIND_VERSION}")
  else()
    set(_pkg_module_spec "libselinux")
  endif()

  pkg_search_module(SELINUX QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  SELINUX
  REQUIRED_VARS SELINUX_LIBRARIES
  VERSION_VAR SELINUX_VERSION
  REASON_FAILURE_MESSAGE "SELINUX not found. Please install SELinux library."
)
