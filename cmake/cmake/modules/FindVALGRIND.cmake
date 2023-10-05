#[=============================================================================[
Find Valgrind.
https://valgrind.org/

The module sets the following variables:

VALGRIND_FOUND
  Set to 1 if Valgrind has been found.
VALGRIND_INCLUDE_DIRS
  A list of Valgrind include directories.
HAVE_VALGRIND
  Set to 1 if Valgrind is enabled.

The VALGRIND_ROOT variable adds search path for finding the Valgrind on custom
locations.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_path(VALGRIND_INCLUDE_DIRS NAMES valgrind.h PATH_SUFFIXES valgrind)

if(VALGRIND_INCLUDE_DIRS)
  set(HAVE_VALGRIND 1 CACHE INTERNAL "Whether to use Valgrind.")
endif()

mark_as_advanced(VALGRIND_INCLUDE_DIRS)

find_package_handle_standard_args(
  VALGRIND
  REQUIRED_VARS VALGRIND_INCLUDE_DIRS
)
