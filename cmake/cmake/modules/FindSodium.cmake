#[=============================================================================[
Find the Sodium library (libsodium).

Module defines the following `IMPORTED` target(s):

* `Sodium::Sodium` - The package library, if found.

Result variables:

* `Sodium_FOUND` - Whether the package has been found.
* `Sodium_INCLUDE_DIRS` - Include directories needed to use this package.
* `Sodium_LIBRARIES` - Libraries needed to link to the package library.
* `Sodium_VERSION` - Package version, if found.

Cache variables:

* `Sodium_INCLUDE_DIR` - Directory containing package library headers.
* `Sodium_LIBRARY` - The path to the package library.

Hints:

The `Sodium_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Sodium
  PROPERTIES
    URL "https://libsodium.org/"
    DESCRIPTION "Crypto library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Sodium QUIET libsodium)

find_path(
  Sodium_INCLUDE_DIR
  NAMES sodium.h
  PATHS ${PC_Sodium_INCLUDE_DIRS}
  DOC "Directory containing Sodium library headers"
)

if(NOT Sodium_INCLUDE_DIR)
  string(APPEND _reason "sodium.h not found. ")
endif()

find_library(
  Sodium_LIBRARY
  NAMES sodium
  PATHS ${PC_Sodium_LIBRARY_DIRS}
  DOC "The path to the Sodium library"
)

if(NOT Sodium_LIBRARY)
  string(APPEND _reason "Sodium library (libsodium) not found. ")
endif()

# Get version.
block(PROPAGATE Sodium_VERSION)
  if(Sodium_INCLUDE_DIR AND EXISTS ${Sodium_INCLUDE_DIR}/sodium/version.h)
    set(regex [[^#[ \t]*define[ \t]+SODIUM_VERSION_STRING[ \t]+"([0-9.]+)"[ \t]*$]])

    file(STRINGS ${Sodium_INCLUDE_DIR}/sodium/version.h results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(Sodium_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()
endblock()

mark_as_advanced(Sodium_INCLUDE_DIR Sodium_LIBRARY)

find_package_handle_standard_args(
  Sodium
  REQUIRED_VARS
    Sodium_LIBRARY
    Sodium_INCLUDE_DIR
  VERSION_VAR Sodium_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Sodium_FOUND)
  return()
endif()

set(Sodium_INCLUDE_DIRS ${Sodium_INCLUDE_DIR})
set(Sodium_LIBRARIES ${Sodium_LIBRARY})

if(NOT TARGET Sodium::Sodium)
  add_library(Sodium::Sodium UNKNOWN IMPORTED)

  set_target_properties(
    Sodium::Sodium
    PROPERTIES
      IMPORTED_LOCATION "${Sodium_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Sodium_INCLUDE_DIR}"
  )
endif()
