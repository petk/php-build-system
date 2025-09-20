#[=============================================================================[
# FindQDBM

Finds the QDBM library:

```cmake
find_package(QDBM [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `QDBM::QDBM` - The package library, if found.

## Result variables

* `QDBM_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `QDBM_VERSION` - The version of package found.

## Cache variables

* `QDBM_INCLUDE_DIR` - Directory containing package library headers.
* `QDBM_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(QDBM)
target_link_libraries(example PRIVATE QDBM::QDBM)
```
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  QDBM
  PROPERTIES
    URL "https://dbmx.net/qdbm/"
    DESCRIPTION "Quick Database Manager library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_QDBM QUIET qdbm)
endif()

find_path(
  QDBM_INCLUDE_DIR
  NAMES depot.h
  PATH_SUFFIXES qdbm
  HINTS ${PC_QDBM_INCLUDE_DIRS}
  DOC "Directory containing QDBM library headers"
)

if(NOT QDBM_INCLUDE_DIR)
  string(APPEND _reason "depot.h not found. ")
endif()

find_library(
  QDBM_LIBRARY
  NAMES qdbm
  HINTS ${PC_QDBM_LIBRARY_DIRS}
  DOC "The path to the QDBM library"
)

if(NOT QDBM_LIBRARY)
  string(APPEND _reason "QDBM library not found. ")
endif()

# Sanity check.
if(QDBM_LIBRARY)
  check_library_exists("${QDBM_LIBRARY}" dpopen "" QDBM_SANITY_CHECK)

  if(NOT QDBM_SANITY_CHECK)
    string(APPEND _reason "Sanity check failed: dpopen not found. ")
  endif()
endif()

block(PROPAGATE QDBM_VERSION)
  if(QDBM_INCLUDE_DIR)
    set(regex "^[ \t]*#[ \t]*define[ \t]+_QDBM_VERSION[ \t]+\"?([0-9.]+)\"?[ \t]*$")

    file(STRINGS ${QDBM_INCLUDE_DIR}/depot.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(QDBM_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

mark_as_advanced(QDBM_INCLUDE_DIR QDBM_LIBRARY)

find_package_handle_standard_args(
  QDBM
  REQUIRED_VARS
    QDBM_LIBRARY
    QDBM_INCLUDE_DIR
    QDBM_SANITY_CHECK
  VERSION_VAR QDBM_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT QDBM_FOUND)
  return()
endif()

if(NOT TARGET QDBM::QDBM)
  add_library(QDBM::QDBM UNKNOWN IMPORTED)

  set_target_properties(
    QDBM::QDBM
    PROPERTIES
      IMPORTED_LOCATION "${QDBM_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${QDBM_INCLUDE_DIR}"
  )
endif()
