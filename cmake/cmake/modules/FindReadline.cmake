#[=============================================================================[
Find the GNU Readline library.

Module defines the following IMPORTED targets:

  Readline::Readline
    The Readline library, if found.

Result variables:

  Readline_FOUND
    Whether GNU Readline library is found.
  Readline_INCLUDE_DIRS
    A list of include directories for using GNU Readline library.
  Readline_LIBRARIES
    A list of libraries for using GNU Readline library.
  Readline_VERSION
    Version string of found GNU Readline library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Readline PROPERTIES
  URL "https://tiswww.case.edu/php/chet/readline/rltop.html"
  DESCRIPTION "Gnu Readline library for command line editing"
)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(Readline_FIND_VERSION)
    set(_pkg_module_spec "readline>=${Readline_FIND_VERSION}")
  else()
    set(_pkg_module_spec "readline")
  endif()

  pkg_search_module(Readline QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Readline
  REQUIRED_VARS Readline_LIBRARIES
  VERSION_VAR Readline_VERSION
  REASON_FAILURE_MESSAGE "Readline not found. Please install Readline library (libreadline)."
)

if(Readline_FOUND AND NOT TARGET Readline::Readline)
  add_library(Readline::Readline INTERFACE IMPORTED)

  set_target_properties(Readline::Readline PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Readline_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Readline_INCLUDE_DIRS}"
  )
endif()
