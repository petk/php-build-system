#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It sets CMake default configuration to manage how CMake works. These can be also
set before calling the project().

Load this module in a CMake project with:

  include(PHP/Internal/CMakeDefaults)
#]=============================================================================]

include_guard(GLOBAL)

# Put the source or build tree include directories before other includes.
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# Add colors to diagnostics output.
if(
  NOT DEFINED CMAKE_COLOR_DIAGNOSTICS
  AND NOT DEFINED ENV{CMAKE_COLOR_DIAGNOSTICS}
)
  set(CMAKE_COLOR_DIAGNOSTICS ON)
endif()

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

# Enable parallel installation (cmake --install <build-dir> -j <jobs>).
set_property(GLOBAL PROPERTY INSTALL_PARALLEL TRUE)
