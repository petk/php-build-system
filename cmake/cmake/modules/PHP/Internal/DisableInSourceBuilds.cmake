#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It disables in-source builds.

Load this module in a CMake project with:

  include(PHP/Internal/DisableInSourceBuilds)

This module:
- prevents running 'cmake .' ('cmake -S <source-dir> -B <source-dir>');
- allows adding the project via add_subdirectory() command or
  FetchContent/ExternalProject modules;
- adds a .gitignore file to binary directory;
#]=============================================================================]

include_guard(GLOBAL)

# Disable in-source builds.
if(CMAKE_BINARY_DIR PATH_EQUAL CMAKE_CURRENT_SOURCE_DIR)
  message(
    FATAL_ERROR
    "In-source builds are disabled (source and build directories must not be "
    "the same). Please, set a pristine build directory.\n"
    "For example:\n"
    "  cmake -B php-build\n"
    "  cmake --build php-build -j"
  )
endif()

# Ignore build directory in Git repository.
block()
  file(GLOB path ${CMAKE_CURRENT_BINARY_DIR}/*)
  if(path PATH_EQUAL ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles)
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/.gitignore "*\n")
  endif()
endblock()
