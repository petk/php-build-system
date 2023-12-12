#[=============================================================================[
Find the GNU Aspell library.

In the past there was also a pspell library which has been superseded by GNU's
Aspell library. The Aspell library provides a simple pspell interface (pspell.h)
for backwards compatibility. On some systems there is a package libpspell-dev,
however relying on it is not encouraged.

Module defines the following IMPORTED targets:

  Aspell::Aspell
    The Aspell library, if found.

Result variables:

  Aspell_FOUND
    Whether Aspell has been found.
  Aspell_INCLUDE_DIRS
    A list of include directories for using Aspell library.
  Aspell_PSPELL_INCLUDE_DIRS
    A list of include directories for using Aspell library with pspell BC
    interface.
  Aspell_LIBRARIES
    A list of libraries for linking when using Aspell library.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Aspell PROPERTIES
  URL "http://aspell.net/"
  DESCRIPTION "GNU Aspell spell checker library"
)

find_path(Aspell_INCLUDE_DIRS aspell.h)

# If there is also pspell interface.
find_path(Aspell_PSPELL_INCLUDE_DIRS pspell.h PATH_SUFFIXES pspell)

if(Aspell_PSPELL_INCLUDE_DIRS)
  list(APPEND Aspell_INCLUDE_DIRS ${Aspell_PSPELL_INCLUDE_DIRS})
endif()

find_library(Aspell_LIBRARIES NAMES aspell DOC "The Aspell library")

# Sanity check.
if(Aspell_LIBRARIES)
  check_library_exists(
    "${Aspell_LIBRARIES}"
    new_aspell_config
    ""
    _aspell_have_new_aspell_config
  )
endif()

mark_as_advanced(Aspell_LIBRARIES Aspell_INCLUDE_DIRS)

find_package_handle_standard_args(
  Aspell
  REQUIRED_VARS Aspell_LIBRARIES Aspell_INCLUDE_DIRS _aspell_have_new_aspell_config
)

if(Aspell_FOUND AND NOT TARGET Aspell::Aspell)
  add_library(Aspell::Aspell INTERFACE IMPORTED)

  set_target_properties(Aspell::Aspell PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Aspell_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Aspell_LIBRARIES}"
  )
endif()
