#[=============================================================================[
Find the Argon2 library.

Module defines the following `IMPORTED` target(s):

* `Argon2::Argon2` - The package library, if found.

Result variables:

* `Argon2_FOUND` - Whether the package has been found.
* `Argon2_INCLUDE_DIRS` - Include directories needed to use this package.
* `Argon2_LIBRARIES` - Libraries needed to link to the package library.
* `Argon2_VERSION` - Package version, if found.

Cache variables:

* `Argon2_INCLUDE_DIR` - Directory containing package library headers.
* `Argon2_LIBRARY` - The path to the package library.

Hints:

The `Argon2_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Argon2
  PROPERTIES
    URL "https://github.com/P-H-C/phc-winner-argon2/"
    DESCRIPTION "The password hash Argon2 library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Argon2 QUIET libargon2)

find_path(
  Argon2_INCLUDE_DIR
  NAMES argon2.h
  PATHS ${PC_Argon2_INCLUDE_DIRS}
  DOC "Directory containing Argon2 library headers"
)

if(NOT Argon2_INCLUDE_DIR)
  string(APPEND _reason "argon2.h not found. ")
endif()

find_library(
  Argon2_LIBRARY
  NAMES argon2
  PATHS ${PC_Argon2_LIBRARY_DIRS}
  DOC "The path to the Argon2 library"
)

if(NOT Argon2_LIBRARY)
  string(APPEND _reason "Argon2 library (libargon2) not found. ")
endif()

# Get version.
block(PROPAGATE Argon2_VERSION)
  # Argon2 headers don't provide version. Try pkgconf version, if found.
  if(PC_Argon2_VERSION)
    cmake_path(
      COMPARE
      "${PC_Argon2_INCLUDEDIR}" EQUAL "${Argon2_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(Argon2_VERSION ${PC_Argon2_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(Argon2_INCLUDE_DIR Argon2_LIBRARY)

find_package_handle_standard_args(
  Argon2
  REQUIRED_VARS
    Argon2_LIBRARY
    Argon2_INCLUDE_DIR
  VERSION_VAR Argon2_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Argon2_FOUND)
  return()
endif()

set(Argon2_INCLUDE_DIRS ${Argon2_INCLUDE_DIR})
set(Argon2_LIBRARIES ${Argon2_LIBRARY})

if(NOT TARGET Argon2::Argon2)
  add_library(Argon2::Argon2 UNKNOWN IMPORTED)

  set_target_properties(
    Argon2::Argon2
    PROPERTIES
      IMPORTED_LOCATION "${Argon2_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Argon2_INCLUDE_DIR}"
  )
endif()
