#[=============================================================================[
Find the QDBM library.

Module defines the following IMPORTED targets:

  QDBM::QDBM
    The QDBM library, if found.

Result variables:

  QDBM_FOUND
    Whether QDBM has been found.
  QDBM_INCLUDE_DIRS
    A list of include directories for using QDBM library.
  QDBM_LIBRARIES
    A list of libraries for linking when using QDBM library.

Hints:

  The QDBM_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(QDBM PROPERTIES
  URL "https://dbmx.net/qdbm/"
  DESCRIPTION "Quick Database Manager library"
)

find_path(QDBM_INCLUDE_DIRS depot.h PATH_SUFFIXES qdbm)

find_library(QDBM_LIBRARIES NAMES qdbm DOC "The QDBM library")

mark_as_advanced(QDBM_LIBRARIES QDBM_INCLUDE_DIRS)

# Sanity check.
check_library_exists("${QDBM_LIBRARIES}" dpopen "" HAVE_DPOPEN)

find_package_handle_standard_args(
  QDBM
  REQUIRED_VARS QDBM_LIBRARIES QDBM_INCLUDE_DIRS HAVE_DPOPEN
)

if(NOT QDBM_FOUND)
  return()
endif()

if(NOT TARGET QDBM::QDBM)
  add_library(QDBM::QDBM INTERFACE IMPORTED)

  set_target_properties(QDBM::QDBM PROPERTIES
    INTERFACE_LINK_LIBRARIES "${QDBM_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${QDBM_INCLUDE_DIRS}"
  )
endif()
