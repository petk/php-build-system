#[=============================================================================[
# FindSodium

Finds the Sodium library (libsodium):

```cmake
find_package(Sodium [<version>] [...])
```

## Imported targets

This module defines the following imported targets:

* `Sodium::Sodium` - The package library, if found.

## Result variables

* `Sodium_FOUND` - Boolean indicating whether the package is found.
* `Sodium_VERSION` - The version of package found.

## Cache variables

* `Sodium_INCLUDE_DIR` - Directory containing package library headers.
* `Sodium_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Sodium)
target_link_libraries(example PRIVATE Sodium::Sodium)
```
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

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_Sodium QUIET libsodium)
endif()

find_path(
  Sodium_INCLUDE_DIR
  NAMES sodium.h
  HINTS ${PC_Sodium_INCLUDE_DIRS}
  DOC "Directory containing Sodium library headers"
)

if(NOT Sodium_INCLUDE_DIR)
  string(APPEND _reason "sodium.h not found. ")
endif()

find_library(
  Sodium_LIBRARY
  NAMES sodium
  HINTS ${PC_Sodium_LIBRARY_DIRS}
  DOC "The path to the Sodium library"
)

if(NOT Sodium_LIBRARY)
  string(APPEND _reason "Sodium library (libsodium) not found. ")
endif()

# Get version.
block(PROPAGATE Sodium_VERSION)
  if(EXISTS ${Sodium_INCLUDE_DIR}/sodium/version.h)
    set(regex "^#[ \t]*define[ \t]+SODIUM_VERSION_STRING[ \t]+\"([0-9.]+)\"[ \t]*$")

    file(STRINGS ${Sodium_INCLUDE_DIR}/sodium/version.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(Sodium_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

mark_as_advanced(Sodium_INCLUDE_DIR Sodium_LIBRARY)

find_package_handle_standard_args(
  Sodium
  REQUIRED_VARS
    Sodium_LIBRARY
    Sodium_INCLUDE_DIR
  VERSION_VAR Sodium_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Sodium_FOUND)
  return()
endif()

if(NOT TARGET Sodium::Sodium)
  add_library(Sodium::Sodium UNKNOWN IMPORTED)

  set_target_properties(
    Sodium::Sodium
    PROPERTIES
      IMPORTED_LOCATION "${Sodium_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Sodium_INCLUDE_DIR}"
  )
endif()
