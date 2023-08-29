#[=============================================================================[
Module for finding the tidy library.

The module sets the following variables:

TIDY_FOUND
  Set to 1 if tidy library has been found.

TIDY_INCLUDE_DIRS
  A list of Tidy library include directories.

TIDY_LIBRARIES
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

find_path(TIDY_INCLUDE_DIRS tidy.h PATH_SUFFIXES tidy)

find_library(TIDY_LIBRARIES NAMES tidy tidy5)

# Check for tidybuffio.h (as opposed to simply buffio.h) which indicates that we
# are building against tidy-html5 and not the legacy htmltidy. The two are
# compatible, except for with regard to this header file.
cmake_push_check_state()
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES} ${TIDY_INCLUDE_DIRS}")
  check_include_file(tidybuffio.h HAVE_TIDYBUFFIO_H)
  check_include_file(tidy.h HAVE_TIDY_H)
cmake_pop_check_state()

foreach(LIBRARY ${TIDY_LIBRARIES})
  check_library_exists(${LIBRARY} tidyOptGetDoc "" HAVE_TIDYOPTGETDOC)
  if(HAVE_TIDYOPTGETDOC)
    break()
  endif()
endforeach()

foreach(LIBRARY ${TIDY_LIBRARIES})
  check_library_exists(${LIBRARY} tidyReleaseDate "" HAVE_TIDYRELEASEDATE)
  if(HAVE_TIDYRELEASEDATE)
    break()
  endif()
endforeach()

mark_as_advanced(TIDY_INCLUDE_DIRS TIDY_LIBRARIES)

find_package_handle_standard_args(
  TIDY
  REQUIRED_VARS TIDY_INCLUDE_DIRS TIDY_LIBRARIES
)
