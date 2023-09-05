#[=============================================================================[
CMake module to find and use the Enchant library.
https://abiword.github.io/enchant/

If enchant library is found, the following variables are set:

ENCHANT_FOUND
  Set to 1 if enchant library is found.
ENCHANT_LIBRARIES
  A list of libraries for using enchant library.
ENCHANT_INCLUDE_DIRS
  A list of include directories for using enchant library.
ENCHANT_VERSION
  Version string of found enchant library.
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
  REASON_FAILURE_MESSAGE "ENCHANT not found. Please install enchant library."
)
