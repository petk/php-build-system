#[=============================================================================[
Find the Sodium library (libsodium).

Module defines the following IMPORTED targets:

  Sodium::Sodium
    The Sodium library, if found.

Result variables:

  Sodium_FOUND
    Whether Sodium library is found.
  Sodium_INCLUDE_DIRS
    A list of include directories for using Sodium library.
  Sodium_LIBRARIES
    A list of libraries for linking when using Sodium library.
  Sodium_VERSION
    Version string of found Sodium library.

Hints:

  The Sodium_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Sodium PROPERTIES
  URL "https://libsodium.org/"
  DESCRIPTION "Crypto library"
)

set(_reason_failure_message)

find_path(Sodium_INCLUDE_DIRS sodium.h)

if(NOT Sodium_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    sodium.h not found."
  )
endif()

find_library(Sodium_LIBRARIES NAMES sodium DOC "The Sodium library")

if(NOT Sodium_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Sodium not found. Please install Sodium library (libsodium)."
  )
endif()

# Get version.
block(PROPAGATE Sodium_VERSION)
  if(Sodium_INCLUDE_DIRS AND EXISTS "${Sodium_INCLUDE_DIRS}/sodium/version.h")
    file(
      STRINGS
      "${Sodium_INCLUDE_DIRS}/sodium/version.h"
      results
      REGEX
      "^#[ \t]*define[ \t]+SODIUM_VERSION_STRING[ \t]+\"[0-9.]+\"[ \t]*$"
    )

    foreach(line ${results})
      if(line MATCHES "^#[ \t]*define[ \t]+SODIUM_VERSION_STRING[ \t]+\"([0-9.]+)\"[ \t]*$")
        set(Sodium_VERSION "${CMAKE_MATCH_1}")
      endif()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  Sodium
  REQUIRED_VARS Sodium_LIBRARIES Sodium_INCLUDE_DIRS
  VERSION_VAR Sodium_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Sodium_FOUND AND NOT TARGET Sodium::Sodium)
  add_library(Sodium::Sodium INTERFACE IMPORTED)

  set_target_properties(Sodium::Sodium PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Sodium_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Sodium_LIBRARIES}"
  )
endif()
