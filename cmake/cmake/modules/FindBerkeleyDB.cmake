#[=============================================================================[
Find the Berkeley DB library.

Set BerkeleyDB_USE_DB1 to TRUE before calling find_package(BerkeleyDB) to enable
the Berkeley DB 1.x support/emulation.

Module defines the following IMPORTED targets:

  BerkeleyDB::BerkeleyDB
    The Berkeley DB library, if found.

Result variables:

  BerkeleyDB_FOUND
    Whether Berkeley DB has been found.
  BerkeleyDB_INCLUDE_DIRS
    A list of include directories for using Berkeley DB library.
  BerkeleyDB_LIBRARIES
    A list of libraries for linking when using Berkeley DB library.
  BerkeleyDB_DB1_VERSION_STRING
    Version string of Berkeley DB 1.x support/emulation.
  BerkeleyDB_DB1_HEADER
    Path to the db_185.h if available.

Hints:

  The BerkeleyDB_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(BerkeleyDB PROPERTIES
  URL "https://www.oracle.com/database/technologies/related/berkeleydb.html"
  DESCRIPTION "Berkeley database library"
)

find_path(BerkeleyDB_INCLUDE_DIRS db.h)

find_library(BerkeleyDB_LIBRARIES NAMES db DOC "The Berkeley DB library")

if(BerkeleyDB_USE_DB1)
  find_path(BerkeleyDB_DB1_INCLUDE_DIRS db_185.h)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${BerkeleyDB_LIBRARIES})
    set(CMAKE_REQUIRED_INCLUDES ${BerkeleyDB_DB1_INCLUDE_DIRS})

    check_source_compiles(C "
      #include <db_185.h>
      int main(void) {
        DB * dbp = dbopen(\"\", 0, 0, DB_HASH, 0);
        return 0;
      }
    " BerkeleyDB_HAVE_DB1)
  cmake_pop_check_state()

  if(BerkeleyDB_DB1_INCLUDE_DIRS AND BerkeleyDB_HAVE_DB1)
    list(APPEND BerkeleyDB_INCLUDE_DIRS ${BerkeleyDB_DB1_INCLUDE_DIRS})
    list(REMOVE_DUPLICATES BerkeleyDB_INCLUDE_DIRS)

    set(BerkeleyDB_DB1_VERSION_STRING "Berkeley DB 1.85 emulation in DB")
    set(BerkeleyDB_DB1_HEADER "${BerkeleyDB_DB1_INCLUDE_DIRS}/db_185.h")
  else()
    message(WARNING "Berkeley DB 1.x support/emulation not found")
  endif()
endif()

mark_as_advanced(BerkeleyDB_LIBRARIES BerkeleyDB_INCLUDE_DIRS)

# Sanity check.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES "${BerkeleyDB_LIBRARIES}")
  set(CMAKE_REQUIRED_INCLUDES "${BerkeleyDB_INCLUDE_DIRS}")

  check_source_compiles(C "
    #include <db.h>

    int main(void) {
      (void)db_create((DB**)0, (DB_ENV*)0, 0);
      return 0;
    }
  " HAVE_BERKELEYDB_LIB)
cmake_pop_check_state()

find_package_handle_standard_args(
  BerkeleyDB
  REQUIRED_VARS BerkeleyDB_LIBRARIES BerkeleyDB_INCLUDE_DIRS HAVE_BERKELEYDB_LIB
)

if(NOT BerkeleyDB_FOUND)
  return()
endif()

if(NOT TARGET BerkeleyDB::BerkeleyDB)
  add_library(BerkeleyDB::BerkeleyDB INTERFACE IMPORTED)

  set_target_properties(BerkeleyDB::BerkeleyDB PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${BerkeleyDB_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${BerkeleyDB_LIBRARIES}"
  )
endif()
