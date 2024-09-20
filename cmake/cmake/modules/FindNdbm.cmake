#[=============================================================================[
Find the ndbm library.

Depending on the system, the nbdm library can be part of other libraries as an
interface.

Module defines the following `IMPORTED` target(s):

* `Ndbm::Ndbm` - The package library, if found.

Result variables:

* `Ndbm_FOUND` - Whether the package has been found.
* `Ndbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Ndbm_LIBRARIES` - Libraries needed to link to the package library.

Cache variables:

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.

Hints:

The `Ndbm_ROOT` variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Ndbm
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/DBM_(computing)"
    DESCRIPTION "A new dbm library"
)

set(_reason "")

find_path(
  Ndbm_INCLUDE_DIR
  NAMES ndbm.h
  PATH_SUFFIXES db1
  DOC "Directory containing ndbm library headers"
)

if(NOT Ndbm_INCLUDE_DIR)
  string(APPEND _reason "ndbm.h not found. ")
endif()

find_library(
  Ndbm_LIBRARY
  NAMES ndbm db1 gdbm_compat c
  DOC "The path to the ndbm library"
)

if(NOT Ndbm_LIBRARY)
  string(APPEND _reason "ndbm library not found. ")
endif()

# Sanity check.
if(Ndbm_LIBRARY)
  check_library_exists("${Ndbm_LIBRARY}" dbm_open "" _ndbm_sanity_check)

  if(NOT _ndbm_sanity_check)
    string(APPEND _reason "Sanity check failed: dbm_open not found. ")
  endif()
endif()

mark_as_advanced(Ndbm_INCLUDE_DIR Ndbm_LIBRARY)

find_package_handle_standard_args(
  Ndbm
  REQUIRED_VARS
    Ndbm_LIBRARY
    Ndbm_INCLUDE_DIR
    _ndbm_sanity_check
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Ndbm_FOUND)
  return()
endif()

set(Ndbm_INCLUDE_DIRS ${Ndbm_INCLUDE_DIR})
set(Ndbm_LIBRARIES ${Ndbm_LIBRARY})

if(NOT TARGET Ndbm::Ndbm)
  add_library(Ndbm::Ndbm UNKNOWN IMPORTED)

  set_target_properties(
    Ndbm::Ndbm
    PROPERTIES
      IMPORTED_LOCATION "${Ndbm_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Ndbm_INCLUDE_DIR}"
  )
endif()
