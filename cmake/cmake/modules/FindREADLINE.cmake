#[=============================================================================[
CMake module to find and use GNU Readline library.
https://tiswww.case.edu/php/chet/readline/rltop.html

If GNU Readline library is found, the following variables are set:

READLINE_FOUND
  Set to 1 if GNU Readline library is found.
READLINE_LIBRARIES
  A list of libraries for using GNU Readline library.
READLINE_INCLUDE_DIRS
  A list of include directories for using GNU Readline library.
READLINE_VERSION
  Version string of found GNU Readline library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  if(READLINE_FIND_VERSION)
    set(_pkg_module_spec "readline>=${READLINE_FIND_VERSION}")
  else()
    set(_pkg_module_spec "readline")
  endif()

  pkg_search_module(READLINE QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  READLINE
  REQUIRED_VARS READLINE_LIBRARIES
  VERSION_VAR READLINE_VERSION
  REASON_FAILURE_MESSAGE "READLINE not found. Please install libreadline."
)
