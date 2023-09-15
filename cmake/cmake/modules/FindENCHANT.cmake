#[=============================================================================[
Find the Enchant library.
https://abiword.github.io/enchant/

If Enchant library is found, the following variables are set:

ENCHANT_FOUND
  Set to 1 if Enchant library is found.
ENCHANT_INCLUDE_DIRS
  A list of include directories for using Enchant library.
ENCHANT_LIBRARIES
  A list of libraries for using Enchant library.
ENCHANT_VERSION
  Version string of found Enchant library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(ENCHANT_FIND_VERSION VERSION_GREATER_EQUAL 2.0)
    set(_pkg_module_spec "enchant-2>=${ENCHANT_FIND_VERSION}")
  elseif(ENCHANT_FIND_VERSION AND ENCHANT_FIND_VERSION VERSION_LESS 2.0)
    set(_pkg_module_spec "enchant>=${ENCHANT_FIND_VERSION}")
  else()
    set(_pkg_module_spec "enchant-2")
  endif()

  pkg_search_module(ENCHANT QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  ENCHANT
  REQUIRED_VARS ENCHANT_LIBRARIES
  VERSION_VAR ENCHANT_VERSION
  REASON_FAILURE_MESSAGE "Enchant not found. Please install enchant library."
)
