#[=============================================================================[
Find the LMDB library.

Module defines the following `IMPORTED` target(s):

* `LMDB::LMDB` - The package library, if found.

Result variables:

* `LMDB_FOUND` - Whether the package has been found.
* `LMDB_INCLUDE_DIRS` - Include directories needed to use this package.
* `LMDB_LIBRARIES` - Libraries needed to link to the package library.
* `LMDB_VERSION` - Package version, if found.

Cache variables:

* `LMDB_INCLUDE_DIR` - Directory containing package library headers.
* `LMDB_LIBRARY` - The path to the package library.

Hints:

The `LMDB_ROOT` variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  LMDB
  PROPERTIES
    URL "https://www.symas.com/lmdb"
    DESCRIPTION "Lightning Memory-Mapped Database library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_LMDB QUIET lmdb)

find_path(
  LMDB_INCLUDE_DIR
  NAMES lmdb.h
  PATHS ${PC_LMDB_INCLUDE_DIRS}
  DOC "Directory containing LMDB library headers"
)

if(NOT LMDB_INCLUDE_DIR)
  string(APPEND _reason "lmdb.h not found. ")
endif()

find_library(
  LMDB_LIBRARY
  NAMES lmdb
  PATHS ${PC_LMDB_LIBRARY_DIRS}
  DOC "The path to the LMDB library"
)

if(NOT LMDB_LIBRARY)
  string(APPEND _reason "LMDB library not found. ")
endif()

# Sanity check.
if(LMDB_LIBRARY)
  check_library_exists("${LMDB_LIBRARY}" mdb_env_open "" _lmdb_sanity_check)

  if(NOT _lmdb_sanity_check)
    string(APPEND _reason "Sanity check failed: mdb_env_open not found. ")
  endif()
endif()

# Get version.
block(PROPAGATE LMDB_VERSION)
  if(LMDB_INCLUDE_DIR)
    file(
      STRINGS
      ${LMDB_INCLUDE_DIR}/lmdb.h
      results
      REGEX
      "^#[ \t]*define[ \t]+MDB_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*$"
    )

    unset(LMDB_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+MDB_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED LMDB_VERSION)
            string(APPEND LMDB_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(LMDB_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(LMDB_INCLUDE_DIR LMDB_LIBRARY)

find_package_handle_standard_args(
  LMDB
  REQUIRED_VARS
    LMDB_LIBRARY
    LMDB_INCLUDE_DIR
    _lmdb_sanity_check
  VERSION_VAR LMDB_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT LMDB_FOUND)
  return()
endif()

set(LMDB_INCLUDE_DIRS ${LMDB_INCLUDE_DIR})
set(LMDB_LIBRARIES ${LMDB_LIBRARY})

if(NOT TARGET LMDB::LMDB)
  add_library(LMDB::LMDB UNKNOWN IMPORTED)

  set_target_properties(
    LMDB::LMDB
    PROPERTIES
      IMPORTED_LOCATION "${LMDB_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${LMDB_INCLUDE_DIR}"
  )
endif()
