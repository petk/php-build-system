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

Hints:

  The Valgrind_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Valgrind PROPERTIES
  URL "https://valgrind.org/"
  DESCRIPTION "Instrumentation framework for building dynamic analysis tools"
  PURPOSE "Detects memory management and threading bugs"
)

set(_reason_failure_message)

find_path(Valgrind_INCLUDE_DIRS NAMES valgrind/valgrind.h)

if(NOT Valgrind_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    valgrind/valgrind.h not found."
  )
endif()

if(Valgrind_INCLUDE_DIRS)
  set(HAVE_VALGRIND 1 CACHE INTERNAL "Whether to use Valgrind.")
endif()

mark_as_advanced(Valgrind_INCLUDE_DIRS)

find_package_handle_standard_args(
  Valgrind
  REQUIRED_VARS Valgrind_INCLUDE_DIRS
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Valgrind_FOUND AND NOT TARGET Valgrind::Valgrind)
  add_library(Valgrind::Valgrind INTERFACE IMPORTED)

  set_target_properties(Valgrind::Valgrind PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Valgrind_INCLUDE_DIRS}"
  )
endif()
