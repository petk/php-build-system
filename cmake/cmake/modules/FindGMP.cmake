#[=============================================================================[
Find the GMP library.

Module defines the following IMPORTED targets:

  GMP::GMP
    The GMP library, if found.

Result variables:

  GMP_FOUND
    Whether GMP library is found.
  GMP_INCLUDE_DIRS
    A list of include directories for using GMP library.
  GMP_LIBRARIES
    A list of libraries for using GMP library.
  GMP_VERSION
    Version string of found GMP library.

Hints:

  The GMP_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(GMP PROPERTIES
  URL "https://gmplib.org/"
  DESCRIPTION "GNU Multiple Precision Arithmetic Library"
)

set(_reason_failure_message)

find_path(GMP_INCLUDE_DIRS gmp.h)

if(NOT GMP_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    gmp.h not found."
  )
endif()

find_library(GMP_LIBRARIES NAMES gmp DOC "The GMP library")

if(NOT GMP_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    GMP library not found. Please install GMP library."
  )
endif()

mark_as_advanced(GMP_LIBRARIES GMP_INCLUDE_DIRS)

# Sanity check.
if(GMP_FIND_VERSION VERSION_GREATER_EQUAL 4.2 AND GMP_LIBRARIES)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_library_exists("${GMP_LIBRARIES}" __gmpz_rootrem "" _gmp_sanity_check)
  cmake_pop_check_state()
else()
  set(_gmp_sanity_check TRUE)
endif()

if(NOT _gmp_sanity_check)
  string(
    APPEND _reason_failure_message
    "\n    GMP sanity check failed - __gmpz_rootrem() not found."
  )
endif()

# Get version.
block(PROPAGATE GMP_VERSION)
  if(GMP_INCLUDE_DIRS)
    file(
      STRINGS
      "${GMP_INCLUDE_DIRS}/gmp.h"
      results
      REGEX
      "^#[ \t]*define[ \t]+__GNU_MP_VERSION(_MINOR|_PATCHLEVEL)?[ \t]+[0-9]+[ \t]*$"
    )

    foreach(item VERSION VERSION_MINOR VERSION_PATCHLEVEL)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+__GNU_MP_${item}[ \t]+([0-9]+)[ \t]*$")
          if(GMP_VERSION)
            string(APPEND GMP_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(GMP_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  GMP
  REQUIRED_VARS GMP_LIBRARIES GMP_INCLUDE_DIRS _gmp_sanity_check
  VERSION_VAR GMP_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(NOT GMP_FOUND)
  return()
endif()

if(NOT TARGET GMP::GMP)
  add_library(GMP::GMP INTERFACE IMPORTED)

  set_target_properties(GMP::GMP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${GMP_LIBRARIES}"
  )
endif()
