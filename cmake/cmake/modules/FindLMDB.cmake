#[=============================================================================[
# FindLMDB

Finds the LMDB library:

```cmake
find_package(LMDB [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `LMDB::LMDB` - The package library, if found.

## Result variables

* `LMDB_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `LMDB_VERSION` - The version of package found.

## Cache variables

* `LMDB_INCLUDE_DIR` - Directory containing package library headers.
* `LMDB_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(LMDB)
target_link_libraries(example PRIVATE LMDB::LMDB)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  LMDB
  PROPERTIES
    URL "https://www.symas.com/mdb"
    DESCRIPTION "Lightning Memory-Mapped Database library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_LMDB QUIET lmdb)
endif()

find_path(
  LMDB_INCLUDE_DIR
  NAMES lmdb.h
  HINTS ${PC_LMDB_INCLUDE_DIRS}
  DOC "Directory containing LMDB library headers"
)

if(NOT LMDB_INCLUDE_DIR)
  string(APPEND _reason "lmdb.h not found. ")
endif()

find_library(
  LMDB_LIBRARY
  NAMES lmdb
  HINTS ${PC_LMDB_LIBRARY_DIRS}
  DOC "The path to the LMDB library"
)

if(NOT LMDB_LIBRARY)
  string(APPEND _reason "LMDB library not found. ")
endif()

# Sanity check.
if(LMDB_INCLUDE_DIR AND LMDB_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${LMDB_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${LMDB_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(mdb_env_open lmdb.h LMDB_SANITY_CHECK)
  cmake_pop_check_state()

  if(NOT LMDB_SANITY_CHECK)
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
    LMDB_SANITY_CHECK
  VERSION_VAR LMDB_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT LMDB_FOUND)
  return()
endif()

if(NOT TARGET LMDB::LMDB)
  add_library(LMDB::LMDB UNKNOWN IMPORTED)

  set_target_properties(
    LMDB::LMDB
    PROPERTIES
      IMPORTED_LOCATION "${LMDB_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${LMDB_INCLUDE_DIR}"
  )
endif()
