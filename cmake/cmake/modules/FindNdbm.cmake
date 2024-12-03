#[=============================================================================[
# FindNdbm

Find the ndbm library.

Depending on the system, the nbdm ("new" dbm) can be part of other libraries as
an interface.

* GNU dbm library (GDBM) has compatibility interface via gdbm_compatibility that
  provides ndbm.h header but it is licensed as GPL 3, which is incompatible with
  PHP.
* Built into default libraries (C): BSD-based systems, macOS, Solaris.

Module defines the following `IMPORTED` target(s):

* `Ndbm::Ndbm` - The package library, if found.

## Result variables

* `Ndbm_FOUND` - Whether the package has been found.
* `Ndbm_IS_BUILT_IN` - Whether ndbm is a part of the C library.
* `Ndbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Ndbm_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.
#]=============================================================================]

include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Ndbm
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/DBM_(computing)"
    DESCRIPTION "A new dbm library"
)

set(_reason "")

# If no compiler is loaded C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(Ndbm_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED Ndbm_IS_BUILT_IN)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(dbm_open "ndbm.h" Ndbm_IS_BUILT_IN)
  cmake_pop_check_state()
endif()

set(_Ndbm_REQUIRED_VARS "")
if(Ndbm_IS_BUILT_IN)
  set(_Ndbm_REQUIRED_VARS _Ndbm_IS_BUILT_IN_MSG)
  set(_Ndbm_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_Ndbm_REQUIRED_VARS Ndbm_INCLUDE_DIR Ndbm_LIBRARY _Ndbm_SANITY_CHECK)

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
    NAMES
      ndbm
      db1
    DOC "The path to the ndbm library"
  )

  if(NOT Ndbm_LIBRARY)
    string(APPEND _reason "ndbm library not found. ")
  endif()

  # Sanity check.
  if(Ndbm_LIBRARY)
    check_library_exists("${Ndbm_LIBRARY}" dbm_open "" _Ndbm_SANITY_CHECK)

    if(NOT _Ndbm_SANITY_CHECK)
      string(APPEND _reason "Sanity check failed: dbm_open not found. ")
    endif()
  endif()

  mark_as_advanced(Ndbm_INCLUDE_DIR Ndbm_LIBRARY)
endif()

find_package_handle_standard_args(
  Ndbm
  REQUIRED_VARS
    ${_Ndbm_REQUIRED_VARS}
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Ndbm_FOUND)
  return()
endif()

if(Ndbm_IS_BUILT_IN)
  set(Ndbm_INCLUDE_DIRS "")
  set(Ndbm_LIBRARIES "")
else()
  set(Ndbm_INCLUDE_DIRS ${Ndbm_INCLUDE_DIR})
  set(Ndbm_LIBRARIES ${Ndbm_LIBRARY})
endif()

if(NOT TARGET Ndbm::Ndbm)
  add_library(Ndbm::Ndbm UNKNOWN IMPORTED)

  if(Ndbm_INCLUDE_DIR)
    set_target_properties(
      Ndbm::Ndbm
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Ndbm_INCLUDE_DIRS}"
    )
  endif()

  if(Ndbm_LIBRARY)
    set_target_properties(
      Ndbm::Ndbm
      PROPERTIES
        IMPORTED_LOCATION "${Ndbm_LIBRARY}"
    )
  endif()
endif()
