cmake_minimum_required(VERSION 3.29...4.2)

# Configure CMake behavior.
include(cmake/CMakeDefaults.cmake)

message(STATUS "Initializing PHP build system")
message(STATUS "=============================")

# Set the PHP_VERSION_* variables from configure.ac.
include(cmake/Version.cmake)

project(
  PHP
  VERSION ${PHP_VERSION}
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C
)

################################################################################
# Configure languages.
################################################################################

# Optionally enable C++ language for PHP extensions.
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)
endif()

# Enable Assembly language dialect.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^ARM")
    enable_language(ASM_MARMASM)
  else()
    enable_language(ASM_MASM)
  endif()
else()
  enable_language(ASM)
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

################################################################################
# Create interface targets providing usage requirements.
################################################################################

# Usage requirements for all PHP-related targets in the build.
add_library(php_config INTERFACE)
add_library(PHP::config ALIAS php_config)
target_include_directories(
  php_config
  INTERFACE
    ${PHP_BINARY_DIR}
    ${PHP_SOURCE_DIR}
)

# Interface library that ties objects and configuration together for PHP SAPIs.
add_library(php_sapi INTERFACE)
add_library(PHP::sapi ALIAS php_sapi)
target_link_libraries(php_sapi INTERFACE PHP::config)

################################################################################
# Configure project.
################################################################################

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

# Check whether IPO/LTO can be enabled.
include(PHP/Optimization)

include(CheckPIESupported)
check_pie_supported()

# Configure build types.
include(cmake/BuildTypes.cmake)

# Set platform-specific configuration.
include(cmake/Platform.cmake)

# Set PHP configuration options and variables.
include(cmake/Configuration.cmake)

# Check requirements.
include(cmake/Requirements.cmake)

# Run PHP configuration checks.
include(cmake/ConfigureChecks.cmake)

# Check compilation options.
include(cmake/Flags.cmake)

add_subdirectory(sapi)
add_subdirectory(ext)
add_subdirectory(Zend)

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring PHP")
message(STATUS "===============")
message(STATUS "")

add_subdirectory(pear)
add_subdirectory(win32)
add_subdirectory(main)
add_subdirectory(scripts)

# Generate *_arginfo.h headers from *.stub.php sources.
include(PHP/Stubs)

# Check thread safety.
include(PHP/ThreadSafety)

################################################################################
# Execute all deferred calls. Calls are additionally sorted with natural
# comparison method by their IDs. If call hasn't set any ID number, CMake
# assigns it a default value of __<number>.
################################################################################

block()
  cmake_language(DEFER GET_CALL_IDS ids)
  list(SORT ids COMPARE NATURAL)
  foreach(id IN LISTS ids)
    cmake_language(DEFER GET_CALL ${id} call)
    list(POP_FRONT call command)
    message(VERBOSE "Executing deferred call: ${command}")
    cmake_language(CALL ${command} ${call})
    cmake_language(DEFER CANCEL_CALL ${id})
  endforeach()
endblock()

# Rebuild all targets as needed.
if(NOT PHPSystem_EXECUTABLE)
  include(PHP/Rebuild)
endif()

# Enable testing and configure test settings.
include(cmake/Testing.cmake)

# Enable and configure CPack module.
include(cmake/CPack.cmake)

include(PHP/FeatureSummary)
php_feature_summary()

message(
  STATUS
  [[License

This software is subject to the PHP License, available in this
distribution in the file LICENSE. By continuing this installation
process, you are bound by the terms of this license agreement.
If you do not agree with the terms of this license, you must abort
the installation process at this point.

Thank you for using PHP.
]]
)
