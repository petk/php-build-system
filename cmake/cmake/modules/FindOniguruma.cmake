#[=============================================================================[
Find the Oniguruma library.

Module defines the following `IMPORTED` target(s):

* `Oniguruma::Oniguruma` - The package library, if found.

Result variables:

* `Oniguruma_FOUND` - Whether the package has been found.
* `Oniguruma_INCLUDE_DIRS` - Include directories needed to use this package.
* `Oniguruma_LIBRARIES` - Libraries needed to link to the package library.
* `Oniguruma_VERSION` - Package version, if found.

Cache variables:

* `Oniguruma_INCLUDE_DIR` - Directory containing package library headers.
* `Oniguruma_LIBRARY` - The path to the package library.

Hints:

The `Oniguruma_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Oniguruma
  PROPERTIES
    URL "https://github.com/kkos/oniguruma"
    DESCRIPTION "Regular expression library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Oniguruma QUIET oniguruma)
endif()

find_path(
  Oniguruma_INCLUDE_DIR
  NAMES oniguruma.h
  HINTS ${PC_Oniguruma_INCLUDE_DIRS}
  DOC "Directory containing Oniguruma library headers"
)

if(NOT Oniguruma_INCLUDE_DIR)
  string(APPEND _reason "oniguruma.h not found. ")
endif()

find_library(
  Oniguruma_LIBRARY
  NAMES onig
  HINTS ${PC_Oniguruma_LIBRARY_DIRS}
  DOC "The path to the Oniguruma library"
)

if(NOT Oniguruma_LIBRARY)
  string(APPEND _reason "Oniguruma library (libonig) not found. ")
endif()

block(PROPAGATE Oniguruma_VERSION)
  if(Oniguruma_INCLUDE_DIR)
    file(
      STRINGS
      ${Oniguruma_INCLUDE_DIR}/oniguruma.h
      results
      REGEX
      "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_(MAJOR|MINOR|TEENY)[ \t]+[0-9]+[ \t]*$"
    )

    unset(Oniguruma_VERSION)

    foreach(item MAJOR MINOR TEENY)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_${item}[ \t]+([0-9]+)[ \t]*$")
          if(DEFINED Oniguruma_VERSION)
            string(APPEND Oniguruma_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Oniguruma_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(Oniguruma_INCLUDE_DIR Oniguruma_LIBRARY)

find_package_handle_standard_args(
  Oniguruma
  REQUIRED_VARS
    Oniguruma_LIBRARY
    Oniguruma_INCLUDE_DIR
  VERSION_VAR Oniguruma_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Oniguruma_FOUND)
  return()
endif()

set(Oniguruma_INCLUDE_DIRS ${Oniguruma_INCLUDE_DIR})
set(Oniguruma_LIBRARIES ${Oniguruma_LIBRARY})

if(NOT TARGET Oniguruma::Oniguruma)
  add_library(Oniguruma::Oniguruma UNKNOWN IMPORTED)

  set_target_properties(
    Oniguruma::Oniguruma
    PROPERTIES
      IMPORTED_LOCATION "${Oniguruma_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Oniguruma_INCLUDE_DIR}"
  )
endif()
