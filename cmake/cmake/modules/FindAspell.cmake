#[=============================================================================[
# FindAspell

Find the GNU Aspell library.

In the past, there was a pspell library, which has been superseded by GNU's
Aspell library. The Aspell library provides a simple pspell interface (pspell.h)
for backward compatibility. On some systems, there is a package called
libpspell-dev; however, relying on it is not encouraged.

Module defines the following `IMPORTED` target(s):

* `Aspell::Aspell` - The package library, if found.

## Result variables

* `Aspell_FOUND` - Whether the package has been found.
* `Aspell_INCLUDE_DIRS` - Include directories needed to use this package.
* `Aspell_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Aspell_INCLUDE_DIR` - Directory containing package library headers.
* `Aspell_LIBRARY` - The path to the package library.
* `Aspell_PSPELL_INCLUDE_DIR` - Directory containing the pspell.h BC interface
  header if available.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Aspell
  PROPERTIES
    URL "http://aspell.net/"
    DESCRIPTION "GNU Aspell spell checker library"
)

set(_reason "")

find_path(
  Aspell_INCLUDE_DIR
  NAMES aspell.h
  DOC "Directory containing Aspell library headers"
)

if(NOT Aspell_INCLUDE_DIR)
  string(APPEND _reason "aspell.h could not be found. ")
endif()

# If there is also pspell interface.
find_path(
  Aspell_PSPELL_INCLUDE_DIR
  NAMES pspell.h
  PATH_SUFFIXES pspell
  DOC "Directory containing pspell.h BC interface header"
)

find_library(
  Aspell_LIBRARY
  NAMES aspell
  DOC "The path to the Aspell library"
)

if(NOT Aspell_LIBRARY)
  string(APPEND _reason "Aspell library not found. ")
endif()

# Sanity check.
if(Aspell_LIBRARY)
  check_library_exists(
    "${Aspell_LIBRARY}"
    new_aspell_config
    ""
    _aspell_sanity_check
  )

  if(NOT _aspell_sanity_check)
    string(APPEND _reason "Sanity check failed: new_aspell_config not found. ")
  endif()
endif()

mark_as_advanced(Aspell_INCLUDE_DIR Aspell_PSPELL_INCLUDE_DIR Aspell_LIBRARY)

find_package_handle_standard_args(
  Aspell
  REQUIRED_VARS
    Aspell_LIBRARY
    Aspell_INCLUDE_DIR
    _aspell_sanity_check
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Aspell_FOUND)
  return()
endif()

set(Aspell_INCLUDE_DIRS ${Aspell_INCLUDE_DIR})
if(Aspell_PSPELL_INCLUDE_DIR)
  list(APPEND Aspell_INCLUDE_DIRS ${Aspell_PSPELL_INCLUDE_DIR})
endif()
set(Aspell_LIBRARIES ${Aspell_LIBRARY})

if(NOT TARGET Aspell::Aspell)
  if(IS_ABSOLUTE "${Aspell_LIBRARY}")
    add_library(Aspell::Aspell UNKNOWN IMPORTED)
    set_target_properties(
      Aspell::Aspell
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${Aspell_LIBRARY}"
    )
  else()
    add_library(Aspell::Aspell INTERFACE IMPORTED)
    set_target_properties(
      Aspell::Aspell
      PROPERTIES
        IMPORTED_LIBNAME "${Aspell_LIBRARY}"
    )
  endif()

  set_target_properties(
    Aspell::Aspell
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Aspell_INCLUDE_DIRS}"
  )
endif()
