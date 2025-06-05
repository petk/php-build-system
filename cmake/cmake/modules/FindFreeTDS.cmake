#[=============================================================================[
# FindFreeTDS

Find the FreeTDS set of libraries.

Module defines the following `IMPORTED` target(s):

* `FreeTDS::FreeTDS` - The package library, if found.

## Result variables

* `FreeTDS_FOUND` - Whether the package has been found.
* `FreeTDS_INCLUDE_DIRS` - Include directories needed to use this package.
* `FreeTDS_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `FreeTDS_INCLUDE_DIR` - Directory containing package library headers.
* `FreeTDS_LIBRARY` - The path to the package library.

## Usage

```cmake
# CMakeLists.txt
find_package(FreeTDS)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  FreeTDS
  PROPERTIES
    URL "https://www.freetds.org/"
    DESCRIPTION "TDS (Tabular DataStream) protocol library for Sybase and MS SQL"
)

set(_reason "")

find_path(
  FreeTDS_INCLUDE_DIR
  NAMES sybdb.h
  PATH_SUFFIXES freetds
  DOC "Directory containing FreeTDS library headers"
)

if(NOT FreeTDS_INCLUDE_DIR)
  string(APPEND _reason "sybdb.h not found. ")
endif()

find_library(
  FreeTDS_LIBRARY
  NAMES sybdb
  DOC "The path to the FreeTDS library"
)

if(NOT FreeTDS_LIBRARY)
  string(APPEND _reason "FreeTDS library not found. ")
endif()

# Sanity check.
if(FreeTDS_INCLUDE_DIR AND FreeTDS_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${FreeTDS_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${FreeTDS_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(dbsqlexec sybdb.h _FreeTDS_SANITY_CHECK)
  cmake_pop_check_state()

  if(NOT _FreeTDS_SANITY_CHECK)
    string(APPEND _reason "Sanity check failed: dbsqlexec not found. ")
  endif()
endif()

mark_as_advanced(FreeTDS_INCLUDE_DIR FreeTDS_LIBRARY)

find_package_handle_standard_args(
  FreeTDS
  REQUIRED_VARS
    FreeTDS_LIBRARY
    FreeTDS_INCLUDE_DIR
    _FreeTDS_SANITY_CHECK
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT FreeTDS_FOUND)
  return()
endif()

set(FreeTDS_INCLUDE_DIRS ${FreeTDS_INCLUDE_DIR})
set(FreeTDS_LIBRARIES ${FreeTDS_LIBRARY})

if(FreeTDS_FOUND AND NOT TARGET FreeTDS::FreeTDS)
  add_library(FreeTDS::FreeTDS UNKNOWN IMPORTED)

  set_target_properties(
    FreeTDS::FreeTDS
    PROPERTIES
      IMPORTED_LOCATION "${FreeTDS_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FreeTDS_INCLUDE_DIRS}"
  )
endif()
