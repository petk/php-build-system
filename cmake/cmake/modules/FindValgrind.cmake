#[=============================================================================[
Find Valgrind.

Module defines the following IMPORTED targets:

  Valgrind::Valgrind
    The Valgrind, if found.

Result variables:

  Valgrind_FOUND
    Whether Valgrind has been found.
  Valgrind_INCLUDE_DIRS
    A list of Valgrind include directories.
  HAVE_VALGRIND
    Whether Valgrind is enabled.

The Valgrind_ROOT variable adds search path for finding the Valgrind on custom
locations.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Valgrind PROPERTIES
  URL "https://valgrind.org/"
  DESCRIPTION "Instrumentation framework for building dynamic analysis tools"
  PURPOSE "Detects memory management and threading bugs"
)

find_path(Valgrind_INCLUDE_DIRS NAMES valgrind.h PATH_SUFFIXES valgrind)

if(Valgrind_INCLUDE_DIRS)
  set(HAVE_VALGRIND 1 CACHE INTERNAL "Whether to use Valgrind.")
endif()

mark_as_advanced(Valgrind_INCLUDE_DIRS)

find_package_handle_standard_args(
  Valgrind
  REQUIRED_VARS Valgrind_INCLUDE_DIRS
)

if(Valgrind_FOUND AND NOT TARGET Valgrind::Valgrind)
  add_library(Valgrind::Valgrind INTERFACE IMPORTED)

  set_target_properties(Valgrind::Valgrind PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Valgrind_INCLUDE_DIRS}"
  )
endif()
