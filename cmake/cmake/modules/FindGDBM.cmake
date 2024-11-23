#[=============================================================================[
# FindGDBM

Find the GDBM library.

Module defines the following `IMPORTED` target(s):

* `GDBM::GDBM` - The package library, if found.

## Result variables

* `GDBM_FOUND` - Whether the package has been found.
* `GDBM_INCLUDE_DIRS` - Include directories needed to use this package.
* `GDBM_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `GDBM_INCLUDE_DIR` - Directory containing package library headers.
* `GDBM_LIBRARY` - The path to the package library.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Dbm
  PROPERTIES
    URL "https://www.gnu.org.ua/software/gdbm/"
    DESCRIPTION "GNU dbm key-value database library"
)

set(_reason "")

find_path(
  GDBM_INCLUDE_DIR
  NAMES gdbm.h
  DOC "Directory containing GDBM library headers"
)

if(NOT GDBM_INCLUDE_DIR)
  string(APPEND _reason "gdbm.h not found. ")
endif()

find_library(
  GDBM_LIBRARY
  NAMES gdbm
  DOC "The path to the GDBM library"
)

if(NOT GDBM_LIBRARY)
  string(APPEND _reason "GDBM library not found. ")
endif()

# Sanity check.
if(GDBM_LIBRARY)
  check_library_exists("${GDBM_LIBRARY}" gdbm_open "" _gdbm_sanity_check)

  if(NOT _gdbm_sanity_check)
    string(APPEND _reason "Sanity check failed: gdbm_open not found. ")
  endif()
endif()

mark_as_advanced(GDBM_INCLUDE_DIR GDBM_LIBRARY)

find_package_handle_standard_args(
  GDBM
  REQUIRED_VARS
    GDBM_LIBRARY
    GDBM_INCLUDE_DIR
    _gdbm_sanity_check
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT GDBM_FOUND)
  return()
endif()

set(GDBM_INCLUDE_DIRS ${GDBM_INCLUDE_DIR})
set(GDBM_LIBRARIES ${GDBM_LIBRARY})

if(NOT TARGET GDBM::GDBM)
  add_library(GDBM::GDBM UNKNOWN IMPORTED)

  set_target_properties(
    GDBM::GDBM
    PROPERTIES
      IMPORTED_LOCATION "${GDBM_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${GDBM_INCLUDE_DIRS}"
  )
endif()
