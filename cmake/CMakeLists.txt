cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# Configure CMake behavior.
include(cmake/CMakeDefaults.cmake)

message("
Initializing PHP build system
-----------------------------
")

message(STATUS "CMake version: ${CMAKE_VERSION}")
message(STATUS "CMake generator: ${CMAKE_GENERATOR}")

# Set the PHP_VERSION_* variables from configure.ac.
include(cmake/Version.cmake)

project(
  PHP
  VERSION ${PHP_VERSION}
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C CXX ASM
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

# Configure project.
include(cmake/Bootstrap.cmake)

message("
Configuring SAPI modules
------------------------
")
add_subdirectory(sapi/apache2handler)
add_subdirectory(sapi/cgi)
add_subdirectory(sapi/cli)
add_subdirectory(sapi/embed)
add_subdirectory(sapi/fpm)
add_subdirectory(sapi/fuzzer)
add_subdirectory(sapi/litespeed)
add_subdirectory(sapi/phpdbg)

message("
Configuring PHP extensions
--------------------------
")
include(PHP/Extensions)
php_extensions_add(ext)

message("
Configuring Zend engine
-----------------------
")
add_subdirectory(Zend)

message("
Configuring PHP
---------------
")
add_subdirectory(pear)
add_subdirectory(TSRM)
add_subdirectory(win32)
add_subdirectory(main)
add_subdirectory(scripts)

# Check thread safety.
include(PHP/ThreadSafety)

# Execute all deferred calls. Calls are additionally sorted with natural
# comparison method by their IDs. If call hasn't set any ID number, CMake
# assigns it a default value of __<number>.
block()
  cmake_language(DEFER GET_CALL_IDS ids)
  list(SORT ids COMPARE NATURAL)
  foreach(id ${ids})
    cmake_language(DEFER GET_CALL ${id} call)
    list(POP_FRONT call command)
    message(STATUS "Executing deferred call: ${command}")
    cmake_language(CALL ${command} ${call})
    cmake_language(DEFER CANCEL_CALL ${id})
  endforeach()
endblock()

# Enable testing and configure test settings.
include(cmake/Testing.cmake)

# Enable and configure CPack module.
include(cmake/CPack.cmake)

include(PHP/FeatureSummary)

message("
License
-------

This software is subject to the PHP License, available in this
distribution in the file LICENSE. By continuing this installation
process, you are bound by the terms of this license agreement.
If you do not agree with the terms of this license, you must abort
the installation process at this point.

Thank you for using PHP.
")
