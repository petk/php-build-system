#[=============================================================================[
Find the Tidy library.

Module defines the following IMPORTED target(s):

  Tidy::Tidy
    The package library, if found.

Result variables:

  Tidy_FOUND
    Whether the package has been found.
  Tidy_INCLUDE_DIRS
    Include directories needed to use this package.
  Tidy_LIBRARIES
    Libraries needed to link to the package library.
  Tidy_VERSION
    Package version, if found.

Cache variables:

  Tidy_INCLUDE_DIR
    Directory containing package library headers.
  Tidy_LIBRARY
    The path to the package library.
  HAVE_TIDYBUFFIO_H
    Whether tidybuffio.h is available.
  HAVE_TIDY_H
    Whether tidy.h is available.
  HAVE_TIDYP_H
    Whether tidy.h is available.
  HAVE_TIDYOPTGETDOC
    Whether tidyOptGetDoc is available in one of tidy libraries.
  HAVE_TIDYRELEASEDATE
    Whether tidyReleaseDate is available in one of tidy libraries.

Hints:

  The Tidy_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckIncludeFile)
include(CheckLibraryExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Tidy
  PROPERTIES
    URL "https://www.html-tidy.org/"
    DESCRIPTION "HTML syntax checker"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Tidy QUIET tidy)

find_path(
  Tidy_INCLUDE_DIR
  NAMES tidy.h
  PATHS ${PC_Tidy_INCLUDE_DIRS}
  PATH_SUFFIXES
    tidy
    tidyp # Tidy library fork (obsolete).
  DOC "Directory containing Tidy library headers"
)

if(NOT Tidy_INCLUDE_DIR)
  string(APPEND _reason "tidy.h not found. ")
endif()

find_library(
  Tidy_LIBRARY
  NAMES tidy tidy5 tidyp
  PATHS ${PC_Tidy_LIBRARY_DIRS}
  DOC "The path to the Tidy library"
)

if(NOT Tidy_LIBRARY)
  string(APPEND _reason "Tidy library not found. ")
endif()

# Check for tidybuffio.h (as opposed to simply buffio.h) which indicates that we
# are building against tidy-html5 and not the legacy htmltidy. The two are
# compatible, except for with regard to this header file.
if(Tidy_INCLUDE_DIR)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${Tidy_INCLUDE_DIR})
    check_include_file(tidybuffio.h HAVE_TIDYBUFFIO_H)
    check_include_file(tidy.h HAVE_TIDY_H)
    check_include_file(tidyp.h HAVE_TIDYP_H)
  cmake_pop_check_state()
endif()

if(Tidy_LIBRARY)
  check_library_exists("${Tidy_LIBRARY}" tidyOptGetDoc "" HAVE_TIDYOPTGETDOC)
  check_library_exists("${Tidy_LIBRARY}" tidyReleaseDate "" HAVE_TIDYRELEASEDATE)
endif()

# Get version.
block(PROPAGATE Tidy_VERSION)
  # Tidy headers don't provide version. Try pkgconf version, if found.
  if(PC_Tidy_VERSION)
    cmake_path(
      COMPARE
      "${PC_Tidy_INCLUDEDIR}" EQUAL "${Tidy_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(Tidy_VERSION ${PC_Tidy_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(Tidy_INCLUDE_DIR Tidy_LIBRARY)

find_package_handle_standard_args(
  Tidy
  REQUIRED_VARS
    Tidy_INCLUDE_DIR
    Tidy_LIBRARY
  VERSION_VAR Tidy_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Tidy_FOUND)
  return()
endif()

set(Tidy_INCLUDE_DIRS ${Tidy_INCLUDE_DIR})
set(Tidy_LIBRARIES ${Tidy_LIBRARY})

if(NOT TARGET Tidy::Tidy)
  add_library(Tidy::Tidy UNKNOWN IMPORTED)

  set_target_properties(
    Tidy::Tidy
    PROPERTIES
      IMPORTED_LOCATION "${Tidy_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Tidy_INCLUDE_DIR}"
  )
endif()
