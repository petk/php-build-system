#[=============================================================================[
Find the Berkeley DB library.

Module defines the following `IMPORTED` target(s):

* `BerkeleyDB::BerkeleyDB` - The package library, if found.

## Result variables

* `BerkeleyDB_FOUND` - Whether the package has been found.
* `BerkeleyDB_INCLUDE_DIRS`- Include directories needed to use this package.
* `BerkeleyDB_LIBRARIES`- Libraries needed to link to the package library.
* `BerkeleyDB_VERSION` - Package version, if found.

## Cache variables

* `BerkeleyDB_INCLUDE_DIR` - Directory containing package library headers.
* `BerkeleyDB_LIBRARY` - The path to the package library.
* `BerkeleyDB_DB1_INCLUDE_DIR` - Directory containing headers for DB1 emulation
  support in Berkeley DB.

## Hints

* The `BerkeleyDB_ROOT` variable adds custom search path.
* Set `BerkeleyDB_USE_DB1` to `TRUE` before calling `find_package(BerkeleyDB)`
  to enable the Berkeley DB 1.x support/emulation.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  BerkeleyDB
  PROPERTIES
    URL "https://www.oracle.com/database/technologies/related/berkeleydb.html"
    DESCRIPTION "Berkeley database library"
)

set(_reason "")

find_path(
  BerkeleyDB_INCLUDE_DIR
  NAMES db.h
  PATH_SUFFIXES db
  DOC "Directory containing Berkeley DB library headers"
)

if(NOT BerkeleyDB_INCLUDE_DIR)
  string(APPEND _reason "db.h not found. ")
endif()

find_library(
  BerkeleyDB_LIBRARY
  NAMES db
  DOC "The path to the Berkeley DB library"
)

if(NOT BerkeleyDB_LIBRARY)
  string(APPEND _reason "Berkeley DB library not found. ")
endif()

if(BerkeleyDB_USE_DB1)
  find_path(
    BerkeleyDB_DB1_INCLUDE_DIR
    NAMES db_185.h
    PATH_SUFFIXES db
    DOC "Directory containing Berkeley DB db_185.h header for v1 emulation"
  )

  message(CHECK_START "Checking for Berkeley DB 1.x support/emulation")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${BerkeleyDB_LIBRARY})
    set(CMAKE_REQUIRED_INCLUDES ${BerkeleyDB_DB1_INCLUDE_DIR})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <db_185.h>
      int main(void)
      {
        DB * dbp = dbopen("", 0, 0, DB_HASH, 0);
        return 0;
      }
    ]] _berkeleydb_db1_sanity_check)
  cmake_pop_check_state()

  if(NOT _berkeleydb_db1_sanity_check)
    unset(BerkeleyDB_DB1_INCLUDE_DIR CACHE)
    message(CHECK_FAIL "disabled, not found")
  else()
    message(CHECK_PASS "enabled")
  endif()
endif()

# Sanity check.
if(BerkeleyDB_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${BerkeleyDB_LIBRARY})
    set(CMAKE_REQUIRED_INCLUDES ${BerkeleyDB_INCLUDE_DIR})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <db.h>

      int main(void)
      {
        (void)db_create((DB**)0, (DB_ENV*)0, 0);
        return 0;
      }
    ]] _berkeleydb_sanity_check)
  cmake_pop_check_state()

  if(NOT _berkeleydb_sanity_check)
    string(APPEND _reason "Sanity check failed: db_create not found. ")
  endif()
endif()

# Get package version.
block(PROPAGATE BerkeleyDB_VERSION)
  if(BerkeleyDB_INCLUDE_DIR)
    file(
      STRINGS
      ${BerkeleyDB_INCLUDE_DIR}/db.h
      results
      REGEX "^[ \t]*#[ \t]*define[ \t]+DB_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[^\r\n]*$"
    )

    unset(BerkeleyDB_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(line MATCHES "^[ \t]*#[ \t]*define[ \t]+DB_VERSION_${item}[ \t]+([0-9]+)[^\r\n]*$")
          if(DEFINED BerkeleyDB_VERSION)
            string(APPEND BerkeleyDB_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(BerkeleyDB_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(
  BerkeleyDB_DB1_INCLUDE_DIR
  BerkeleyDB_INCLUDE_DIR
  BerkeleyDB_LIBRARY
)

find_package_handle_standard_args(
  BerkeleyDB
  REQUIRED_VARS
    BerkeleyDB_LIBRARY
    BerkeleyDB_INCLUDE_DIR
    _berkeleydb_sanity_check
  VERSION_VAR BerkeleyDB_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT BerkeleyDB_FOUND)
  return()
endif()

set(
  BerkeleyDB_INCLUDE_DIRS
  ${BerkeleyDB_INCLUDE_DIR}
  ${BerkeleyDB_DB1_INCLUDE_DIR}
)
list(REMOVE_DUPLICATES BerkeleyDB_INCLUDE_DIRS)
set(BerkeleyDB_LIBRARIES ${BerkeleyDB_LIBRARY})

if(NOT TARGET BerkeleyDB::BerkeleyDB)
  add_library(BerkeleyDB::BerkeleyDB UNKNOWN IMPORTED)

  set_target_properties(
    BerkeleyDB::BerkeleyDB
    PROPERTIES
      IMPORTED_LOCATION "${BerkeleyDB_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${BerkeleyDB_INCLUDE_DIR};${BerkeleyDB_DB1_INCLUDE_DIR}"
  )
endif()
