#[=============================================================================[
# FindEditline

Finds the Editline library:

```cmake
find_package(Editline)
```

## Imported targets

This module defines the following imported targets:

* `Editline::Editline` - The Editline library, if found.

## Result variables

* `Editline_FOUND` - Whether the package has been found.
* `Editline_INCLUDE_DIRS` - Include directories needed to use this package.
* `Editline_LIBRARIES` - Libraries needed to link to the package library.
* `Editline_VERSION` - Package version, if found.

## Cache variables

* `Editline_INCLUDE_DIR` - Directory containing package library headers.
* `Editline_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Editline)
target_link_libraries(example PRIVATE Editline::Editline)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Editline
  PROPERTIES
    URL "https://thrysoee.dk/editline/"
    DESCRIPTION "Command-line editing, history, and tokenization library"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Editline QUIET libedit)
endif()

find_path(
  Editline_INCLUDE_DIR
  NAMES editline/readline.h
  HINTS ${PC_Editline_INCLUDE_DIRS}
  DOC "Directory containing Editline library headers"
)

if(NOT Editline_INCLUDE_DIR)
  string(APPEND _reason "editline/readline.h not found. ")
endif()

find_library(
  Editline_LIBRARY
  NAMES edit
  HINTS ${PC_Editline_LIBRARY_DIRS}
  DOC "The path to the Editline library"
)

if(NOT Editline_LIBRARY)
  string(APPEND _reason "Editline library not found. ")
endif()

# Sanity check.
if(Editline_INCLUDE_DIR AND Editline_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${Editline_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${Editline_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(readline editline/readline.h _Editline_SANITY_CHECK)
  cmake_pop_check_state()

  if(NOT _Editline_SANITY_CHECK)
    string(APPEND _reason "Sanity check failed: readline() not found. ")
  endif()
endif()

# Editline headers don't provide version. Try pkg-config.
if(
  PC_Editline_VERSION
  AND Editline_INCLUDE_DIR IN_LIST PC_Editline_INCLUDE_DIRS
)
  set(Editline_VERSION ${PC_Editline_VERSION})
endif()

mark_as_advanced(Editline_INCLUDE_DIR Editline_LIBRARY)

find_package_handle_standard_args(
  Editline
  REQUIRED_VARS
    Editline_LIBRARY
    Editline_INCLUDE_DIR
    _Editline_SANITY_CHECK
  VERSION_VAR Editline_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Editline_FOUND)
  return()
endif()

set(Editline_INCLUDE_DIRS ${Editline_INCLUDE_DIR})
set(Editline_LIBRARIES ${Editline_LIBRARY})

if(NOT TARGET Editline::Editline)
  add_library(Editline::Editline UNKNOWN IMPORTED)

  set_target_properties(
    Editline::Editline
    PROPERTIES
      IMPORTED_LOCATION "${Editline_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Editline_INCLUDE_DIRS}"
  )
endif()
