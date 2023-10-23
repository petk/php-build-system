#[=============================================================================[
Find the Tidy library.
https://www.html-tidy.org/

Module defines the following IMPORTED targets:

  Tidy::Tidy
    The Tidy library, if found.

Result variables:

  Tidy_FOUND
    Set to 1 if tidy library has been found.
  Tidy_INCLUDE_DIRS
    A list of Tidy library include directories.
  Tidy_LIBRARIES
    A list of Tidy libraries.
  HAVE_TIDYBUFFIO_H
    Set to 1 if tidybuffio.h header is available.
  HAVE_TIDY_H
    Set to 1 if tidy.h is available.
  HAVE_TIDYOPTGETDOC
    Set to 1 if tidyOptGetDoc is available in one of tidy libraries.
  HAVE_TIDYRELEASEDATE
    Set to 1 if tidyReleaseDate is available in one of tidy libraries.
#]=============================================================================]

include(CheckIncludeFile)
include(CheckLibraryExists)
include(CMakePushCheckState)
include(FindPackageHandleStandardArgs)

find_path(Tidy_INCLUDE_DIRS tidy.h PATH_SUFFIXES tidy)

find_library(Tidy_LIBRARIES NAMES tidy tidy5 DOC "The Tidy library")

# Check for tidybuffio.h (as opposed to simply buffio.h) which indicates that we
# are building against tidy-html5 and not the legacy htmltidy. The two are
# compatible, except for with regard to this header file.
cmake_push_check_state(RESET)
  if(Tidy_INCLUDE_DIRS)
    set(CMAKE_REQUIRED_INCLUDES ${Tidy_INCLUDE_DIRS})
  endif()
  check_include_file(tidybuffio.h HAVE_TIDYBUFFIO_H)
  check_include_file(tidy.h HAVE_TIDY_H)
cmake_pop_check_state()

if(Tidy_LIBRARIES)
  check_library_exists(${Tidy_LIBRARIES} tidyOptGetDoc "" HAVE_TIDYOPTGETDOC)
  check_library_exists(${Tidy_LIBRARIES} tidyReleaseDate "" HAVE_TIDYRELEASEDATE)
endif()

mark_as_advanced(Tidy_INCLUDE_DIRS Tidy_LIBRARIES)

find_package_handle_standard_args(
  Tidy
  REQUIRED_VARS Tidy_INCLUDE_DIRS Tidy_LIBRARIES
)

if(Tidy_FOUND AND NOT TARGET Tidy::Tidy)
  add_library(Tidy::Tidy INTERFACE IMPORTED)

  set_target_properties(Tidy::Tidy PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Tidy_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Tidy_INCLUDE_DIRS}"
  )
endif()
