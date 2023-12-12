#[=============================================================================[
Find the mm library.

Module defines the following IMPORTED targets:

  MM::MM
    The mm library, if found.

Result variables:

  MM_FOUND
    Whether mm library is found.
  MM_INCLUDE_DIRS
    A list of include directories for using mm library.
  MM_LIBRARIES
    A list of libraries for using mm library.

Hints:

  The MM_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(MM PROPERTIES
  URL "http://www.ossp.org/pkg/lib/mm/"
  DESCRIPTION "Shared memory allocation library"
)

find_path(MM_INCLUDE_DIRS NAMES mm.h)

find_library(MM_LIBRARIES NAMES mm DOC "The mm library")

find_package_handle_standard_args(
  MM
  REQUIRED_VARS MM_INCLUDE_DIRS MM_LIBRARIES
)

mark_as_advanced(MM_INCLUDE_DIRS MM_LIBRARIES)

if(MM_FOUND AND NOT TARGET MM::MM)
  add_library(MM::MM INTERFACE IMPORTED)

  set_target_properties(MM::MM PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${MM_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${MM_LIBRARIES}"
  )
endif()
