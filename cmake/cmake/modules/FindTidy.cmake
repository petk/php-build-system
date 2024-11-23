#[=============================================================================[
# FindTidy

Find the Tidy library (tidy-html5, legacy htmltidy library, or the tidyp -
obsolete fork).

Module defines the following `IMPORTED` target(s):

* `Tidy::Tidy` - The package library, if found.

## Result variables

* `Tidy_FOUND` - Whether the package has been found.
* `Tidy_INCLUDE_DIRS` - Include directories needed to use this package.
* `Tidy_LIBRARIES` - Libraries needed to link to the package library.
* `Tidy_VERSION` - Package version, if found.

## Cache variables

* `Tidy_INCLUDE_DIR` - Directory containing package library headers.
* `Tidy_LIBRARY` - The path to the package library.
* `HAVE_TIDYBUFFIO_H` - Whether tidybuffio.h is available.
* `HAVE_TIDY_H` - Whether `tidy.h` is available.
* `HAVE_TIDYP_H` - If `tidy.h` is not available and whether the `tidyp.h` is
  available (tidy fork).
#]=============================================================================]

include(CheckIncludeFile)
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

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Tidy QUIET tidy)
endif()

find_path(
  Tidy_INCLUDE_DIR
  NAMES
    tidy.h
    tidyp.h # Tidy library fork (obsolete)
  HINTS ${PC_Tidy_INCLUDE_DIRS}
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
  NAMES
    tidy
    tidy5 # tidy-html5 on FreeBSD
    tidyp
  HINTS ${PC_Tidy_LIBRARY_DIRS}
  DOC "The path to the Tidy library"
)

if(NOT Tidy_LIBRARY)
  string(APPEND _reason "Tidy library not found. ")
endif()

if(Tidy_INCLUDE_DIR)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${Tidy_INCLUDE_DIR})

    # Check for tidybuffio.h (as opposed to simply buffio.h) which indicates
    # that the found library is tidy-html5 and not the legacy htmltidy. The two
    # are compatible, except the legacy doesn't have this header.
    check_include_file(tidybuffio.h HAVE_TIDYBUFFIO_H)

    check_include_file(tidy.h HAVE_TIDY_H)
    if(NOT HAVE_TIDY_H)
      check_include_file(tidyp.h HAVE_TIDYP_H)
    endif()
  cmake_pop_check_state()
endif()

# Tidy headers don't provide version. Try pkg-config.
if(PC_Tidy_VERSION AND Tidy_INCLUDE_DIR IN_LIST PC_Tidy_INCLUDE_DIRS)
  set(Tidy_VERSION ${PC_Tidy_VERSION})
endif()

mark_as_advanced(Tidy_INCLUDE_DIR Tidy_LIBRARY)

find_package_handle_standard_args(
  Tidy
  REQUIRED_VARS
    Tidy_INCLUDE_DIR
    Tidy_LIBRARY
  VERSION_VAR Tidy_VERSION
  HANDLE_VERSION_RANGE
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
      INTERFACE_INCLUDE_DIRECTORIES "${Tidy_INCLUDE_DIRS}"
  )
endif()
