#[=============================================================================[
Find the dbm library.

Depending on the system, the dbm library can be part of other libraries as an
interface.

* GNU dbm has compatibility interface via gdbm_compatibility
* TODO: Built into default libraries (C): Solaris still has some macros
  definitions mapping to internal dbm functions available in the db.h header.
  When defining `DB_DBM_HSEARCH` dbm handler is available as built into C
  library. However, this is museum code and probably relying on a standalone dbm
  package instead should be done without using this artifact. PHP in the past
  already used this and moved the db extension out of the php-src to PECL.

Module defines the following `IMPORTED` target(s):

* `Dbm::Dbm` - The package library, if found.

## Result variables

* `Dbm_FOUND` - Whether the package has been found.
* `Dbm_IS_BUILT_IN` - Whether dbm is a part of the C library.
* `Dbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Dbm_LIBRARIES` - Libraries needed to link to the package library.
* `Dbm_IMPLEMENTATION` - String of the library name that implements the dbm
  library.

## Cache variables

* `Dbm_INCLUDE_DIR` - Directory containing package library headers.
* `Dbm_LIBRARY` - The path to the package library.
#]=============================================================================]

include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Dbm
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/DBM_(computing)"
    DESCRIPTION "A key-value database library"
)

set(_reason "")

# If no compiler is loaded C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(Dbm_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED Dbm_IS_BUILT_IN)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(dbminit dbm.h Dbm_IS_BUILT_IN)
  cmake_pop_check_state()
endif()

set(_Dbm_REQUIRED_VARS)
if(Dbm_IS_BUILT_IN)
  set(_Dbm_REQUIRED_VARS _Dbm_IS_BUILT_IN_MSG)
  set(_Dbm_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_Dbm_REQUIRED_VARS Dbm_INCLUDE_DIR Dbm_LIBRARY _Dbm_SANITY_CHECK)

  find_path(
    Dbm_INCLUDE_DIR
    NAMES dbm.h
    PATH_SUFFIXES gdbm
    DOC "Directory containing dbm library headers"
  )

  if(NOT Dbm_INCLUDE_DIR)
    string(APPEND _reason "dbm.h not found. ")
  endif()

  find_library(
    Dbm_LIBRARY
    NAMES
      gdbm_compat
      dbm
    DOC "The path to the dbm library"
  )

  if(NOT Dbm_LIBRARY)
    string(APPEND _reason "dbm library not found. ")
  endif()

  # Sanity check.
  if(Dbm_LIBRARY)
    check_library_exists("${Dbm_LIBRARY}" dbminit "" _Dbm_SANITY_CHECK)

    if(NOT _dbm_sanity_check)
      string(APPEND _reason "Sanity check failed: dbminit not found. ")
    endif()
  endif()

  mark_as_advanced(Dbm_INCLUDE_DIR Dbm_LIBRARY)
endif()

if(Dbm_LIBRARY MATCHES "gdbm_compat")
  set(Dbm_IMPLEMENTATION "GDBM")
elseif(Dbm_LIBRARY)
  set(Dbm_IMPLEMENTATION "DBM")
endif()

find_package_handle_standard_args(
  Dbm
  REQUIRED_VARS
    ${_Dbm_REQUIRED_VARS}
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Dbm_FOUND)
  return()
endif()

if(Dbm_IS_BUILT_IN)
  set(Dbm_INCLUDE_DIRS "")
  set(Dbm_LIBRARIES "")
else()
  set(Dbm_INCLUDE_DIRS ${Dbm_INCLUDE_DIR})
  set(Dbm_LIBRARIES ${Dbm_LIBRARY})
endif()

if(NOT TARGET Dbm::Dbm)
  add_library(Dbm::Dbm UNKNOWN IMPORTED)

  if(Dbm_INCLUDE_DIRS)
    set_target_properties(
      Dbm::Dbm
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Dbm_INCLUDE_DIRS}"
    )
  endif()

  if(Dbm_LIBRARY)
    set_target_properties(
      Dbm::Dbm
      PROPERTIES
        IMPORTED_LOCATION "${Dbm_LIBRARY}"
    )
  endif()
endif()
