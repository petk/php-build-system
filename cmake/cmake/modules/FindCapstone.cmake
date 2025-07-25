#[=============================================================================[
# FindCapstone

Finds the Capstone library:

```cmake
find_package(Capstone)
```

## Imported targets

This module defines the following imported targets:

* `Capstone::Capstone` - The package library, if found.

## Result variables

* `Capstone_FOUND` - Whether the package has been found.
* `Capstone_INCLUDE_DIRS` - Include directories needed to use this package.
* `Capstone_LIBRARIES` - Libraries needed to link to the package library.
* `Capstone_VERSION` - Package version, if found.

## Cache variables

* `Capstone_INCLUDE_DIR` - Directory containing package library headers.
* `Capstone_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Capstone)
target_link_libraries(example PRIVATE Capstone::Capstone)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Capstone
  PROPERTIES
    URL "https://www.capstone-engine.org"
    DESCRIPTION "Disassembly engine"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Capstone QUIET capstone)
endif()

find_path(
  Capstone_INCLUDE_DIR
  NAMES capstone/capstone.h
  HINTS ${PC_Capstone_INCLUDE_DIRS}
  DOC "Directory containing Capstone library headers"
)

if(NOT Capstone_INCLUDE_DIR)
  string(APPEND _reason "capstone/capstone.h not found. ")
endif()

find_library(
  Capstone_LIBRARY
  NAMES capstone
  HINTS ${PC_Capstone_LIBRARY_DIRS}
  DOC "The path to the Capstone library"
)

if(NOT Capstone_LIBRARY)
  string(APPEND _reason "Capstone library not found. ")
endif()

block(PROPAGATE Capstone_VERSION)
  if(Capstone_INCLUDE_DIR)
    file(
      STRINGS
      "${Capstone_INCLUDE_DIR}/capstone/capstone.h"
      results
      REGEX
      "^#[ \t]*define[ \t]+CS_(API_MAJOR|API_MINOR|VERSION_EXTRA)[ \t]+[0-9]+[ \t]*$"
    )

    set(Capstone_VERSION "")

    foreach(item CS_API_MAJOR CS_API_MINOR CS_VERSION_EXTRA)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+${item}[ \t]+([0-9]+)[ \t]*$")
          if(Capstone_VERSION)
            string(APPEND Capstone_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Capstone_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()

    if(
      NOT Capstone_VERSION
      AND PC_Capstone_VERSION
      AND Capstone_INCLUDE_DIR IN_LIST PC_Capstone_INCLUDE_DIRS
    )
      set(Capstone_VERSION ${PC_Capstone_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(Capstone_INCLUDE_DIR Capstone_LIBRARY)

find_package_handle_standard_args(
  Capstone
  REQUIRED_VARS
    Capstone_LIBRARY
    Capstone_INCLUDE_DIR
  VERSION_VAR Capstone_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Capstone_FOUND)
  return()
endif()

# Capstone might be included with <capstone.h> instead of the recommended
# <capstone/capstone.h>. Here both include directories are added so the code can
# work with both includes. The "subdir" can be removed and simplified in the
# future. See: https://github.com/capstone-engine/capstone/issues/1982
set(
  Capstone_INCLUDE_DIRS
  ${Capstone_INCLUDE_DIR}
  ${Capstone_INCLUDE_DIR}/capstone
)
set(Capstone_LIBRARIES ${Capstone_LIBRARY})

if(NOT TARGET Capstone::Capstone)
  if(IS_ABSOLUTE "${Capstone_LIBRARY}")
    add_library(Capstone::Capstone UNKNOWN IMPORTED)
    set_target_properties(
      Capstone::Capstone
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${Capstone_LIBRARY}"
    )
  else()
    add_library(Capstone::Capstone INTERFACE IMPORTED)
    set_target_properties(
      Capstone::Capstone
      PROPERTIES
        IMPORTED_LIBNAME "${Capstone_LIBRARY}"
    )
  endif()

  set_target_properties(
    Capstone::Capstone
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Capstone_INCLUDE_DIRS}"
  )
endif()
