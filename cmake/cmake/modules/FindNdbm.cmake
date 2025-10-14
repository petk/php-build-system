#[=============================================================================[
# FindNdbm

Finds the ndbm library:

```cmake
find_package(Ndbm)
```

Depending on the system, the nbdm ("new" dbm) can be part of other libraries as
an interface.

* GNU dbm library (GDBM) has compatibility interface via gdbm_compatibility that
  provides ndbm.h header but it is licensed as GPL 3, which is incompatible with
  PHP.
* Built into default libraries (C): BSD-based systems, macOS, Solaris.

## Imported targets

This module provides the following imported targets:

* `Ndbm::Ndbm` - The package library, if found.

## Result variables

This module defines the following variables:

* `Ndbm_FOUND` - Boolean indicating whether the package was found.
* `Ndbm_IS_BUILT_IN` - Whether ndbm is a part of the C library.

## Cache variables

The following cache variables may also be set:

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Ndbm)
target_link_libraries(example PRIVATE Ndbm::Ndbm)
```
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
    check_symbol_exists(dbm_open ndbm.h Ndbm_IS_BUILT_IN)
  cmake_pop_check_state()
endif()

set(_Ndbm_REQUIRED_VARS "")
if(Ndbm_IS_BUILT_IN)
  set(_Ndbm_REQUIRED_VARS _Ndbm_IS_BUILT_IN_MSG)
  set(_Ndbm_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_Ndbm_REQUIRED_VARS Ndbm_INCLUDE_DIR Ndbm_LIBRARY Ndbm_SANITY_CHECK)

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
    NAMES_PER_DIR
    DOC "The path to the ndbm library"
  )

  if(NOT Ndbm_LIBRARY)
    string(APPEND _reason "ndbm library not found. ")
  endif()

  # Sanity check.
  if(Ndbm_LIBRARY)
    check_library_exists("${Ndbm_LIBRARY}" dbm_open "" Ndbm_SANITY_CHECK)

    if(NOT Ndbm_SANITY_CHECK)
      string(APPEND _reason "Sanity check failed: dbm_open not found. ")
    endif()
  endif()

  mark_as_advanced(Ndbm_INCLUDE_DIR Ndbm_LIBRARY)
endif()

find_package_handle_standard_args(
  Ndbm
  REQUIRED_VARS ${_Ndbm_REQUIRED_VARS}
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Ndbm_FOUND)
  return()
endif()

if(NOT TARGET Ndbm::Ndbm)
  add_library(Ndbm::Ndbm UNKNOWN IMPORTED)

  if(Ndbm_INCLUDE_DIR)
    set_target_properties(
      Ndbm::Ndbm
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Ndbm_INCLUDE_DIR}"
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
