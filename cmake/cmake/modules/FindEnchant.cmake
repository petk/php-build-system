#[=============================================================================[
# FindEnchant

Finds the Enchant library:

```cmake
find_package(Enchant [<version>] [...])
```

Enchant uses different library names based on the version - `enchant-2` for
version 2.x and `enchant` for earlier versions < 2.0.

## Imported targets

This module defines the following imported targets:

* `Enchant::Enchant` - The package library, if found.

## Result variables

* `Enchant_FOUND` - Boolean indicating whether the package is found.
* `Enchant_VERSION` - The version of package found.

## Cache variables

* `Enchant_INCLUDE_DIR` - Directory containing package library headers.
* `Enchant_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Enchant)
target_link_libraries(example PRIVATE Enchant::Enchant)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Enchant
  PROPERTIES
    URL "https://abiword.github.io/enchant/"
    DESCRIPTION "Interface for a number of spellchecking libraries"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_search_module(PC_Enchant QUIET enchant-2 enchant)
endif()

find_path(
  Enchant_INCLUDE_DIR
  NAMES enchant.h
  PATH_SUFFIXES enchant-2
  HINTS ${PC_Enchant_INCLUDE_DIRS}
  DOC "Directory containing Enchant library headers"
)

if(NOT Enchant_INCLUDE_DIR)
  string(APPEND _reason "enchant.h not found. ")
endif()

find_library(
  Enchant_LIBRARY
  NAMES enchant-2 enchant
  HINTS ${PC_Enchant_LIBRARY_DIRS}
  DOC "The path to the Enchant library"
)

if(NOT Enchant_LIBRARY)
  string(APPEND _reason "Enchant library not found. ")
endif()

# Enchant headers don't provide version. Try pkg-config.
if(PC_Enchant_VERSION AND Enchant_INCLUDE_DIR IN_LIST PC_Enchant_INCLUDE_DIRS)
  set(Enchant_VERSION ${PC_Enchant_VERSION})
endif()

mark_as_advanced(Enchant_INCLUDE_DIR Enchant_LIBRARY)

find_package_handle_standard_args(
  Enchant
  REQUIRED_VARS
    Enchant_LIBRARY
    Enchant_INCLUDE_DIR
  VERSION_VAR Enchant_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Enchant_FOUND)
  return()
endif()

if(NOT TARGET Enchant::Enchant)
  add_library(Enchant::Enchant UNKNOWN IMPORTED)

  set_target_properties(
    Enchant::Enchant
    PROPERTIES
      IMPORTED_LOCATION "${Enchant_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Enchant_INCLUDE_DIR}"
  )
endif()
