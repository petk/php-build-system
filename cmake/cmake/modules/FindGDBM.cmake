#[=============================================================================[
Find the GDBM library.

Module defines the following IMPORTED targets:

  GDBM::GDBM
    The GDBM library, if found.

Result variables:

  GDBM_FOUND
    Whether GDBM has been found.
  GDBM_INCLUDE_DIRS
    A list of include directories for using GDBM library.
  GDBM_LIBRARIES
    A list of libraries for linking when using GDBM library.

Hints:

  The GDBM_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Dbm PROPERTIES
  URL "https://www.gnu.org.ua/software/gdbm/"
  DESCRIPTION "GNU dbm key-value database library"
)

find_path(GDBM_INCLUDE_DIRS gdbm.h)

find_library(GDBM_LIBRARIES NAMES gdbm DOC "The GDBM library")

mark_as_advanced(GDBM_LIBRARIES GDBM_INCLUDE_DIRS)

# Sanity check.
check_library_exists("${GDBM_LIBRARIES}" gdbm_open "" HAVE_GDBM_OPEN)

find_package_handle_standard_args(
  GDBM
  REQUIRED_VARS GDBM_LIBRARIES GDBM_INCLUDE_DIRS HAVE_GDBM_OPEN
)

if(NOT GDBM_FOUND)
  return()
endif()

if(NOT TARGET GDBM::GDBM)
  add_library(GDBM::GDBM INTERFACE IMPORTED)

  set_target_properties(GDBM::GDBM PROPERTIES
    INTERFACE_LINK_LIBRARIES "${GDBM_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${GDBM_INCLUDE_DIRS}"
  )
endif()
