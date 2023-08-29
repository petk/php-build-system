#[=============================================================================[
CMake module to find and use the GNU Aspell library.

In the past there was also a pspell library which has been superseded by GNU's
Aspell library. The Aspell library provides a simple pspell interface (pspell.h)
for backwards compatibility. On some systems there is a package libpspell-dev,
however relying on it is not encouraged.

If Aspell has been found, the following variables are set:

ASPELL_FOUND
ASPELL_INCLUDE_DIRS
ASPELL_LIBRARIES
#]=============================================================================]

include(CheckLibraryExists)
include(FindPackageHandleStandardArgs)

find_path(ASPELL_INCLUDE_DIRS aspell.h)

# If there is also pspell interface.
find_path(_pspell_include_dir pspell.h PATH_SUFFIXES pspell)
if(_pspell_include_dir)
  list(APPEND ASPELL_INCLUDE_DIRS "${_pspell_include_dir}")
endif()

unset(_pspell_include_dir CACHE)

find_library(ASPELL_LIBRARIES NAMES aspell)

check_library_exists(aspell new_aspell_config "" _have_aspell)

mark_as_advanced(ASPELL_LIBRARIES ASPELL_INCLUDE_DIRS)

find_package_handle_standard_args(
  ASPELL
  REQUIRED_VARS ASPELL_LIBRARIES ASPELL_INCLUDE_DIRS _have_aspell
)
