#[=============================================================================[
Setting CMake defaults to manage how CMake works. These can be set before
calling the project().

https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html
#]=============================================================================]

include_guard(GLOBAL)

# Set CMake module paths where include() and find_package() look for modules.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/modules)

# Automatically include current source or build tree for the current target.
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Put the source or build tree include directories before other includes.
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# Add colors to diagnostics output.
if(
  NOT DEFINED CMAKE_COLOR_DIAGNOSTICS
  AND NOT DEFINED ENV{CMAKE_COLOR_DIAGNOSTICS}
)
  set(CMAKE_COLOR_DIAGNOSTICS ON)
endif()

# Disable PIC for all targets. PIC is enabled for shared extensions manually.
set(CMAKE_POSITION_INDEPENDENT_CODE OFF)

# Set empty prefix for targets instead of default "lib".
set(CMAKE_SHARED_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_MODULE_PREFIX_C "")
set(CMAKE_STATIC_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_LIBRARY_PREFIX_CXX "")
set(CMAKE_SHARED_MODULE_PREFIX_CXX "")
set(CMAKE_STATIC_LIBRARY_PREFIX_CXX "")

# Whether to enable verbose output from Makefile builds.
option(CMAKE_VERBOSE_MAKEFILE "Enable verbose output from Makefile builds" OFF)
mark_as_advanced(CMAKE_VERBOSE_MAKEFILE)

# Whether to show message context in configuration log.
option(
  CMAKE_MESSAGE_CONTEXT_SHOW
  "Show message context in configuration log, where possible"
  OFF
)
mark_as_advanced(CMAKE_MESSAGE_CONTEXT_SHOW)

# Whether to build all libraries as shared.
option(BUILD_SHARED_LIBS "Build enabled PHP extensions as shared libraries" OFF)

# Treat all compile warnings as errors at the build phase, if compiler supports
# such compile option, like -Werror, /WX, or similar.
option(
  CMAKE_COMPILE_WARNING_AS_ERROR
  "Treat all compile warnings as errors at the build phase"
  OFF
)
mark_as_advanced(CMAKE_COMPILE_WARNING_AS_ERROR)
