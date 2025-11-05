#[=============================================================================[
Setting CMake defaults to manage how CMake works. These can be set before
calling the project().

https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html
#]=============================================================================]

include_guard(GLOBAL)

# Disable in-source builds.
if(CMAKE_BINARY_DIR PATH_EQUAL CMAKE_CURRENT_SOURCE_DIR)
  message(
    FATAL_ERROR
    "In-source builds are disabled. Please, set the build directory.\n"
    "For example:\n"
    "  cmake -B php-build\n"
    "  cmake --build php-build -j"
  )
endif()

# Ignore build directory in Git repository.
block()
  file(GLOB files "${CMAKE_CURRENT_BINARY_DIR}/*")
  if(files PATH_EQUAL ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles)
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/.gitignore "*\n")
  endif()
endblock()

# Add paths where include() and find_package() look for modules.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/modules)

# Put the source or build tree include directories before other includes.
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# Add colors to diagnostics output.
if(
  NOT DEFINED CMAKE_COLOR_DIAGNOSTICS
  AND NOT DEFINED ENV{CMAKE_COLOR_DIAGNOSTICS}
)
  set(CMAKE_COLOR_DIAGNOSTICS ON)
endif()

# Set empty prefix for targets instead of default "lib".
set(CMAKE_SHARED_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_MODULE_PREFIX_C "")
set(CMAKE_STATIC_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_LIBRARY_PREFIX_CXX "")
set(CMAKE_SHARED_MODULE_PREFIX_CXX "")
set(CMAKE_STATIC_LIBRARY_PREFIX_CXX "")

# Whether to show message context in configuration log.
option(
  CMAKE_MESSAGE_CONTEXT_SHOW
  "Show message context in configuration log, where possible"
)
mark_as_advanced(CMAKE_MESSAGE_CONTEXT_SHOW)

# Treat all compile warnings as errors at the build phase, if compiler supports
# such compile option, like -Werror, /WX, or similar.
option(
  CMAKE_COMPILE_WARNING_AS_ERROR
  "Treat all compile warnings as errors at the build phase"
)
mark_as_advanced(CMAKE_COMPILE_WARNING_AS_ERROR)

# Set default visibility of all symbols to hidden if the compiler (for example,
# GCC >= 4) supports it. This can help reduce the binary size and startup time.
set(CMAKE_C_VISIBILITY_PRESET "hidden")
