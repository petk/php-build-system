#[=============================================================================[
Find the Enchant library.

Module defines the following IMPORTED targets:

  Enchant::Enchant
    The Enchant library, if found.

Result variables:

  Enchant_FOUND
    Whether Enchant library is found.
  Enchant_INCLUDE_DIRS
    A list of include directories for using Enchant library.
  Enchant_LIBRARIES
    A list of libraries for using Enchant library.
  Enchant_VERSION
    Version string of found Enchant library.

Hints:

  TODO: The Enchant_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Enchant PROPERTIES
  URL "https://abiword.github.io/enchant/"
  DESCRIPTION "Interface for a number of spellchecking libraries"
)

find_package(PkgConfig QUIET REQUIRED)

if(PKG_CONFIG_FOUND)
  if(Enchant_FIND_VERSION VERSION_GREATER_EQUAL 2.0)
    set(_pkg_module_spec "enchant-2>=${Enchant_FIND_VERSION}")
  elseif(Enchant_FIND_VERSION AND Enchant_FIND_VERSION VERSION_LESS 2.0)
    set(_pkg_module_spec "enchant>=${Enchant_FIND_VERSION}")
  else()
    set(_pkg_module_spec "enchant-2")
  endif()

  pkg_search_module(Enchant QUIET "${_pkg_module_spec}")

  unset(_pkg_module_spec)
endif()

find_package_handle_standard_args(
  Enchant
  REQUIRED_VARS Enchant_LIBRARIES
  VERSION_VAR Enchant_VERSION
  REASON_FAILURE_MESSAGE "Enchant not found. Please install Enchant library."
)

if(Enchant_FOUND AND NOT TARGET Enchant::Enchant)
  add_library(Enchant::Enchant INTERFACE IMPORTED)

  set_target_properties(Enchant::Enchant PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Enchant_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Enchant_LIBRARIES}"
  )
endif()
