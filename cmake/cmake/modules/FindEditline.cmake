#[=============================================================================[
Find the Editline library.

Module defines the following `IMPORTED` target(s):

* `Editline::Editline` - The Editline library, if found.

Result variables:

* `Editline_FOUND` - Whether the package has been found.
* `Editline_INCLUDE_DIRS` - Include directories needed to use this package.
* `Editline_LIBRARIES` - Libraries needed to link to the package library.
* `Editline_VERSION` - Package version, if found.

Cache variables:

* `Editline_INCLUDE_DIR` - Directory containing package library headers.
* `Editline_LIBRARY` - The path to the package library.

Hints:

The `Editline_ROOT` variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Editline
  PROPERTIES
    URL "https://thrysoee.dk/editline/"
    DESCRIPTION "Command-line editing, history, and tokenization library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Editline QUIET libedit)

find_path(
  Editline_INCLUDE_DIR
  NAMES editline/readline.h
  PATHS ${PC_Editline_INCLUDE_DIRS}
  DOC "Directory containing Editline library headers"
)

if(NOT Editline_INCLUDE_DIR)
  string(APPEND _reason "editline/readline.h not found. ")
endif()

find_library(
  Editline_LIBRARY
  NAMES edit
  PATHS ${PC_Editline_LIBRARY_DIRS}
  DOC "The path to the Editline library"
)

if(NOT Editline_LIBRARY)
  string(APPEND _reason "Editline library not found. ")
endif()

# Sanity check.
if(Editline_LIBRARY)
  check_library_exists(
    "${Editline_LIBRARY}"
    readline
    ""
    _editline_sanity_check
  )

  if(NOT _editline_sanity_check)
    string(APPEND _reason "Sanity check failed: readline() not found. ")
  endif()
endif()

# Get version.
block(PROPAGATE Editline_VERSION)
  # Editline headers don't provide version. Try pkgconf version, if found.
  if(PC_Editline_VERSION)
    cmake_path(
      COMPARE
      "${PC_Editline_INCLUDEDIR}" EQUAL "${Editline_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(Editline_VERSION ${PC_Editline_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(Editline_INCLUDE_DIR Editline_LIBRARY)

find_package_handle_standard_args(
  Editline
  REQUIRED_VARS
    Editline_LIBRARY
    Editline_INCLUDE_DIR
    _editline_sanity_check
  VERSION_VAR Editline_VERSION
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
      INTERFACE_INCLUDE_DIRECTORIES "${Editline_INCLUDE_DIR}"
  )
endif()
