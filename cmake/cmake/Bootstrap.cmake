#[=============================================================================[
Configure project after the project() call.
#]=============================================================================]

include_guard(GLOBAL)

define_property(
  TARGET
  PROPERTY PHP_CLI
  BRIEF_DOCS "Whether the PHP SAPI or extension is CLI-based"
)

define_property(
  TARGET
  PROPERTY PHP_SAPI_FASTCGI
  BRIEF_DOCS "Whether the PHP SAPI is FastCGI-based"
)

# Optionally enable CXX for extensions.
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)
endif()

# Check whether IPO/LTO can be enabled.
include(PHP/Optimization)

# Set CMAKE_POSITION_INDEPENDENT_CODE.
include(PHP/PositionIndependentCode)

# INTERFACE library with usage requirements.
add_library(php_config INTERFACE)
add_library(PHP::config ALIAS php_config)
target_include_directories(
  php_config
  INTERFACE
    ${PHP_BINARY_DIR}
    ${PHP_SOURCE_DIR}
)

# INTERFACE library that ties objects and configuration together for PHP SAPIs.
add_library(php_sapi INTERFACE)
add_library(PHP::sapi ALIAS php_sapi)
target_link_libraries(php_sapi INTERFACE PHP::config)

# Configure build types.
include(cmake/BuildTypes.cmake)

# Set platform-specific configuration.
include(cmake/Platform.cmake)

# Set PHP configuration options and variables.
include(cmake/Configuration.cmake)

# Check requirements.
include(cmake/Requirements.cmake)

message(STATUS "")
message(STATUS "")
message(STATUS "Running system checks")
message(STATUS "=====================")
message(STATUS "")

# Run PHP configuration checks.
include(cmake/ConfigureChecks.cmake)

# Check compilation options.
include(cmake/Flags.cmake)
