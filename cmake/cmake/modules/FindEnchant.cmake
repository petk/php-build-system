#[=============================================================================[
Find the Enchant library.

Module defines the following `IMPORTED` target(s):

* `Enchant::Enchant` - The package library, if found.

Result variables:

* `Enchant_FOUND` - Whether the package has been found.
* `Enchant_INCLUDE_DIRS` - Include directories needed to use this package.
* `Enchant_LIBRARIES` - Libraries needed to link to the package library.
* `Enchant_VERSION` - Package version, if found.

Cache variables:

* `Enchant_INCLUDE_DIR` - Directory containing package library headers.
* `Enchant_LIBRARY` - The path to the package library.

Hints:

The `Enchant_ROOT` variable adds custom search path.
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

# Enchant uses different library names based on the version.
if(Enchant_FIND_VERSION VERSION_GREATER_EQUAL 2.0)
  set(_enchant_name enchant-2)
else()
  set(_enchant_name enchant)
endif()

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Enchant QUIET ${_enchant_name})

find_path(
  Enchant_INCLUDE_DIR
  NAMES enchant.h
  PATHS ${PC_Enchant_INCLUDE_DIRS}
  DOC "Directory containing Enchant library headers"
)

if(NOT Enchant_INCLUDE_DIR)
  string(APPEND _reason "enchant.h not found. ")
endif()

find_library(
  Enchant_LIBRARY
  NAMES ${_enchant_name}
  PATHS ${PC_Enchant_LIBRARY_DIRS}
  DOC "The path to the Enchant library"
)

if(NOT Enchant_LIBRARY)
  string(APPEND _reason "Enchant library not found. ")
endif()

# Get version.
block(PROPAGATE Enchant_VERSION)
  # Enchant headers don't provide version. Try pkgconf version, if found.
  if(PC_Enchant_VERSION)
    cmake_path(
      COMPARE
      "${PC_Enchant_INCLUDEDIR}" EQUAL "${Enchant_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(Enchant_VERSION ${PC_Enchant_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(Enchant_INCLUDE_DIR Enchant_LIBRARY)

find_package_handle_standard_args(
  Enchant
  REQUIRED_VARS
    Enchant_LIBRARY
    Enchant_INCLUDE_DIR
  VERSION_VAR Enchant_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_enchant_name)

if(NOT Enchant_FOUND)
  return()
endif()

set(Enchant_INCLUDE_DIRS ${Enchant_INCLUDE_DIR})
set(Enchant_LIBRARIES ${Enchant_LIBRARY})

if(NOT TARGET Enchant::Enchant)
  add_library(Enchant::Enchant UNKNOWN IMPORTED)

  set_target_properties(
    Enchant::Enchant
    PROPERTIES
      IMPORTED_LOCATION "${Enchant_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Enchant_INCLUDE_DIR}"
  )
endif()
