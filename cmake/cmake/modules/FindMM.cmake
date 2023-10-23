#[=============================================================================[
Find the mm library.
http://www.ossp.org/pkg/lib/mm/

Module defines the following IMPORTED targets:

  MM::MM
    The mm library, if found.

Result variables:

  MM_FOUND
    Set to 1 if mm library is found.
  MM_INCLUDE_DIRS
    A list of include directories for using mm library.
  MM_LIBRARIES
    A list of libraries for using mm library.

Hints:

  The MM_ROOT variable adds search path for finding the mmlib on custom
  locations.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

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
    INTERFACE_LINK_LIBRARIES "${MM_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${MM_INCLUDE_DIRS}"
  )
endif()
