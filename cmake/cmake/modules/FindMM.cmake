#[=============================================================================[
Find the mm library.

Module defines the following `IMPORTED` target(s):

* `MM::MM` - The package library, if found.

Result variables:

* `MM_FOUND` - Whether the package has been found.
* `MM_INCLUDE_DIRS` - Include directories needed to use this package.
* `MM_LIBRARIES` - Libraries needed to link to the package library.

Cache variables:

* `MM_INCLUDE_DIR` - Directory containing package library headers.
* `MM_LIBRARY` - The path to the package library.

Hints:

The `MM_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  MM
  PROPERTIES
    URL "http://www.ossp.org/pkg/lib/mm/"
    DESCRIPTION "Shared memory allocation library"
)

set(_reason "")

find_path(
  MM_INCLUDE_DIR
  NAMES mm.h
  DOC "Directory containing mm library headers"
)

if(NOT MM_INCLUDE_DIR)
  string(APPEND _reason "mm.h not found. ")
endif()

find_library(
  MM_LIBRARY
  NAMES mm
  DOC "The path to the mm library"
)

if(NOT MM_LIBRARY)
  string(APPEND _reason "mm library not found. ")
endif()

mark_as_advanced(MM_INCLUDE_DIR MM_LIBRARY)

find_package_handle_standard_args(
  MM
  REQUIRED_VARS
    MM_INCLUDE_DIR
    MM_LIBRARY
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT MM_FOUND)
  return()
endif()

set(MM_INCLUDE_DIRS ${MM_INCLUDE_DIR})
set(MM_LIBRARIES ${MM_LIBRARY})

if(NOT TARGET MM::MM)
  add_library(MM::MM UNKNOWN IMPORTED)

  set_target_properties(
    MM::MM
    PROPERTIES
      IMPORTED_LOCATION "${MM_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${MM_INCLUDE_DIRS}"
  )
endif()
