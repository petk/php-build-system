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
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set(_gmp_url "https://gmplib.org/")
set(_gmp_description "GNU Multiple Precision Arithmetic Library")

set_package_properties(GMP PROPERTIES
  URL "${_gmp_url}"
  DESCRIPTION "${_gmp_description}"
)

find_path(GMP_INCLUDE_DIRS gmp.h)

find_library(GMP_LIBRARIES NAMES gmp DOC "The GMP library")

mark_as_advanced(GMP_LIBRARIES GMP_INCLUDE_DIRS)

# Sanity check.
if(GMP_FIND_VERSION VERSION_GREATER_EQUAL 4.2 AND GMP_LIBRARIES)
  check_library_exists("${GMP_LIBRARIES}" __gmpz_rootrem "" _gmp_sanity_check)
else()
  set(_gmp_sanity_check TRUE)
endif()

# Get version.
if(GMP_INCLUDE_DIRS)
  unset(GMP_VERSION)

  file(
    STRINGS
    "${GMP_INCLUDE_DIRS}/gmp.h"
    _gmp_version_string
    REGEX
    "^#[ \t]*define[ \t]+__GNU_MP_VERSION(_MINOR|_PATCHLEVEL)?[ \t]+[0-9]+[ \t]*$"
  )

  foreach(version_part VERSION VERSION_MINOR VERSION_PATCHLEVEL)
    foreach(version_line ${_gmp_version_string})
      set(
        _gmp_regex
        "^#[ \t]*define[ \t]+__GNU_MP_${version_part}[ \t]+([0-9]+)[ \t]*$"
      )

      if(version_line MATCHES "${_gmp_regex}")
        if(GMP_VERSION)
          string(APPEND GMP_VERSION ".${CMAKE_MATCH_1}")
        else()
          set(GMP_VERSION "${CMAKE_MATCH_1}")
        endif()
      endif()
    endforeach()
  endforeach()

  unset(_gmp_version_string)
endif()

find_package_handle_standard_args(
  GMP
  REQUIRED_VARS GMP_LIBRARIES GMP_INCLUDE_DIRS _gmp_sanity_check
  VERSION_VAR GMP_VERSION
  REASON_FAILURE_MESSAGE "Please install GMP, ${_gmp_description} <${_gmp_url}>"
)

if(NOT GMP_FOUND)
  return()
endif()

if(NOT TARGET GMP::GMP)
  add_library(GMP::GMP INTERFACE IMPORTED)

  set_target_properties(GMP::GMP PROPERTIES
    INTERFACE_LINK_LIBRARIES "${GMP_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIRS}"
  )
endif()
