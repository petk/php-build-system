#[=============================================================================[
Configure project after the project() call.
#]=============================================================================]

include_guard(GLOBAL)

# Optionally enable CXX for extensions.
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)
endif()

# Output linker information.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
  if(CMAKE_C_COMPILER_LINKER)
    message(STATUS "C linker: ${CMAKE_C_COMPILER_LINKER}")
  endif()
  if(CMAKE_CXX_COMPILER_LINKER)
    message(STATUS "CXX linker: ${CMAKE_CXX_COMPILER_LINKER}")
  endif()
endif()

# Check whether to enable interprocedural optimization.
include(PHP/InterproceduralOptimization)

# Set CMAKE_POSITION_INDEPENDENT_CODE.
include(PHP/PositionIndependentCode)

# Create a project wide INTERFACE library with project configuration.
add_library(php_configuration INTERFACE)
add_library(PHP::configuration ALIAS php_configuration)
target_include_directories(
  php_configuration
  INTERFACE
    ${PHP_BINARY_DIR}
    ${PHP_SOURCE_DIR}
)

# Create a custom target for generating files (parsers, lexers, etc.) manually:
#   cmake --build <dir> -t php_generate_files
add_custom_target(php_generate_files)

# Configure build types.
include(cmake/BuildTypes.cmake)

# Set platform-specific configuration.
include(cmake/Platform.cmake)

# Set PHP configuration options and variables.
include(cmake/Configuration.cmake)

# Check requirements.
include(cmake/Requirements.cmake)

message(STATUS "---------------------")
message(STATUS "Running system checks")
message(STATUS "---------------------\n")

# Run PHP configuration checks.
include(cmake/ConfigureChecks.cmake)

# Check compilation options.
include(cmake/Flags.cmake)
