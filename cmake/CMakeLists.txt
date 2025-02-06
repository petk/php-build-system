cmake_minimum_required(VERSION 3.25...3.31)

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
  LANGUAGES C ASM
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

# Configure project.
include(cmake/Bootstrap.cmake)

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

# Execute all deferred calls. Calls are additionally sorted with natural
# comparison method by their IDs. If call hasn't set any ID number, CMake
# assigns it a default value of __<number>.
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
