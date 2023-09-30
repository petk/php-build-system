#[=============================================================================[
Find the MM library.
http://www.ossp.org/pkg/lib/mm/

If MM library (libmm) is found, the following variables are set:

MM_FOUND
  Set to 1 if MM library is found.
MM_INCLUDE_DIRS
  A list of include directories for using MM library.
MM_LIBRARIES
  A list of libraries for using MM library.

The MM_ROOT variable adds search path for finding the mmlib on custom locations.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_path(MM_INCLUDE_DIRS NAMES mm.h)

find_library(MM_LIBRARIES NAMES mm)

find_package_handle_standard_args(
  MM
  REQUIRED_VARS MM_INCLUDE_DIRS MM_LIBRARIES
)

mark_as_advanced(MM_INCLUDE_DIRS MM_LIBRARIES)
