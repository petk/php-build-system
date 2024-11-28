#[=============================================================================[
# FindCdb

Find the cdb library.

Module defines the following `IMPORTED` target(s):

* `Cdb::Cdb` - The package library, if found.

## Result variables

* `Cdb_FOUND` - Whether the package has been found.
* `Cdb_INCLUDE_DIRS` - Include directories needed to use this package.
* `Cdb_LIBRARIES` - Libraries needed to link to the package library.
* `Cdb_VERSION` - Package version, if found.

## Cache variables

* `Cdb_INCLUDE_DIR` - Directory containing package library headers.
* `Cdb_LIBRARY` - The path to the package library.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Cdb
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/Cdb_(software)"
    DESCRIPTION "A constant database library"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Cdb QUIET libcdb)
endif()

find_path(
  Cdb_INCLUDE_DIR
  NAMES cdb.h
  HINTS ${PC_Cdb_INCLUDE_DIRS}
  DOC "Directory containing cdb library headers"
)

if(NOT Cdb_INCLUDE_DIR)
  string(APPEND _reason "cdb.h not found. ")
endif()

find_library(
  Cdb_LIBRARY
  NAMES cdb
  HINTS ${PC_Cdb_LIBRARY_DIRS}
  DOC "The path to the cdb library"
)

if(NOT Cdb_LIBRARY)
  string(APPEND _reason "cdb library not found. ")
endif()

# Sanity check.
if(Cdb_LIBRARY)
  check_library_exists("${Cdb_LIBRARY}" cdb_read "" _cdb_sanity_check)

  if(NOT _cdb_sanity_check)
    string(APPEND _reason "Sanity check failed: cdb_read not found. ")
  endif()
endif()

# Get version.
block(PROPAGATE Cdb_VERSION)
  if(Cdb_INCLUDE_DIR)
    set(regex "^[ \t]*#[ \t]*define[ \t]+TINYCDB_VERSION[ \t]+([0-9.]+)[ \t]*$")

    file(STRINGS ${Cdb_INCLUDE_DIR}/cdb.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(Cdb_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

mark_as_advanced(Cdb_INCLUDE_DIR Cdb_LIBRARY)

find_package_handle_standard_args(
  Cdb
  REQUIRED_VARS
    Cdb_LIBRARY
    Cdb_INCLUDE_DIR
    _cdb_sanity_check
  VERSION_VAR Cdb_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Cdb_FOUND)
  return()
endif()

set(Cdb_INCLUDE_DIRS ${Cdb_INCLUDE_DIR})
set(Cdb_LIBRARIES ${Cdb_LIBRARY})

if(NOT TARGET Cdb::Cdb)
  add_library(Cdb::Cdb UNKNOWN IMPORTED)

  set_target_properties(
    Cdb::Cdb
    PROPERTIES
      IMPORTED_LOCATION "${Cdb_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Cdb_INCLUDE_DIRS}"
  )
endif()
