#[=============================================================================[
Find and use PHP command line SAPI.
https://www.php.net/

The module sets the following variables:

PHP_EXECUTABLE
  Path to the php program.
PHP_FOUND
  Set to true if the program was found, false otherwise.
PHP_VERSION
  Version of php program.

The minimum required version of php can be specified using the standard CMake
syntax, e.g. 'find_package(PHP 8.3.0)'.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

# Check if current binary directory contains built CLI SAPI. Otherwise, find
# system php binary if it exists.
if(EXISTS ${CMAKE_BINARY_DIR}/sapi/cli/php)
  set(PHP_EXECUTABLE ${CMAKE_BINARY_DIR}/sapi/cli/php CACHE INTERNAL "Path to the php executable" FORCE)
else()
  find_program(PHP_EXECUTABLE php DOC "Path to the php executable")
endif()

if(PHP_EXECUTABLE)
  execute_process(COMMAND ${PHP_EXECUTABLE} --version OUTPUT_VARIABLE PHP_VERSION_RAW OUTPUT_STRIP_TRAILING_WHITESPACE)

  string(REGEX MATCH "(PHP [0-9]+)\\.([0-9]+)\\.([0-9]+).*$" _ ${PHP_VERSION_RAW})
  set(PHP_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}" CACHE INTERNAL "PHP Version" FORCE)
endif()

find_package_handle_standard_args(
  PHP
  REQUIRED_VARS PHP_EXECUTABLE
  VERSION_VAR PHP_VERSION
)
