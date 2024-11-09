#[=============================================================================[
Find the Capstone library.

Module defines the following `IMPORTED` target(s):

* `Capstone::Capstone` - The package library, if found.

Result variables:

* `Capstone_FOUND` - Whether the package has been found.
* `Capstone_INCLUDE_DIRS` - Include directories needed to use this package.
* `Capstone_LIBRARIES` - Libraries needed to link to the package library.
* `Capstone_VERSION` - Package version, if found.

Cache variables:

* `Capstone_INCLUDE_DIR` - Directory containing package library headers.
* `Capstone_LIBRARY` - The path to the package library.

Hints:

The `Capstone_ROOT` variable adds custom search path.
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

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Capstone QUIET capstone)
endif()

find_path(
  Capstone_INCLUDE_DIR
  NAMES capstone/capstone.h
  PATHS ${PC_Capstone_INCLUDE_DIRS}
  DOC "Directory containing Capstone library headers"
)

if(NOT Capstone_INCLUDE_DIR)
  string(APPEND _reason "capstone/capstone.h not found. ")
endif()

find_library(
  Capstone_LIBRARY
  NAMES capstone
  PATHS ${PC_Capstone_LIBRARY_DIRS}
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

    unset(Capstone_VERSION)

    foreach(item CS_API_MAJOR CS_API_MINOR CS_VERSION_EXTRA)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED Capstone_VERSION)
            string(APPEND Capstone_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Capstone_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(Capstone_INCLUDE_DIR Capstone_LIBRARY)

find_package_handle_standard_args(
  Capstone
  REQUIRED_VARS
    Capstone_LIBRARY
    Capstone_INCLUDE_DIR
  VERSION_VAR Capstone_VERSION
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
block(PROPAGATE Capstone_INCLUDE_DIRS Capstone_LIBRARIES)
  set(subdir "${Capstone_INCLUDE_DIR}/capstone")

  set(Capstone_INCLUDE_DIRS ${Capstone_INCLUDE_DIR} ${subdir})
  set(Capstone_LIBRARIES ${Capstone_LIBRARY})

  if(NOT TARGET Capstone::Capstone)
    add_library(Capstone::Capstone UNKNOWN IMPORTED)

    set_target_properties(
      Capstone::Capstone
      PROPERTIES
        IMPORTED_LOCATION "${Capstone_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Capstone_INCLUDE_DIR};${subdir}"
    )
  endif()
endblock()
