#!/usr/bin/env -S cmake -P
#
#[=============================================================================[
Standalone CMake helper script that downloads PHP tarball, applies PHP source
code patches and adds CMake files for running CMake commands on the PHP sources.

After running this script, there will be tarball file and extracted directory
available.

This script is not part of the CMake build system itself but is only a simple
wrapper to be able to use CMake in PHP sources and written in CMake way to be
as portable as possible on different systems.

SYNOPSIS:
  ./bin/php.cmake [<PHP_VERSION>]

    PHP version to download in form of {MAJOR}.{MINOR}.{PATCH}{EXTRA}

Usage examples:
  cmake -P bin/php.cmake 8.3.0RC1
  ./bin/php.cmake 8.3.0RC1
#]=============================================================================]

# Set default variables.
set(PHP_VERSION "8.3.0RC1")

if(CMAKE_ARGV3)
  set(PHP_VERSION "${CMAKE_ARGV3}")
endif()

if(NOT PHP_VERSION MATCHES "^8\\.[0-9]\\.[0-9]+[a-zA-Z0-9\\-]*$")
  message(FATAL_ERROR "PHP version should match pattern {MAJOR}.{MINOR}.{PATCH}{EXTRA}")
endif()

# Determine the download URL.
if(PHP_VERSION MATCHES ".*-dev")
  set(_download_url "https://github.com/php/php-src/archive/refs/heads/master.tar.gz")
else()
  set(_download_url "https://downloads.php.net/~jakub/php-${PHP_VERSION}.tar.gz")
endif()

set(_php_tarball "php-${PHP_VERSION}.tar.gz")
set(_php_directory "php-${PHP_VERSION}")

if(EXISTS "${_php_directory}")
  message(FATAL_ERROR "To continue, please remove previous existing directory ${_php_directory}")
endif()

function(check_url)
  unset(URL_FOUND)

  set(check_url_command curl --silent --head --fail ${ARGN})

  execute_process(
    COMMAND ${check_url_command}
    RESULT_VARIABLE URL_FOUND
    OUTPUT_QUIET
  )

  if(URL_FOUND EQUAL 0)
    set(URL_FOUND 1 CACHE INTERNAL "URL found")
  else()
    set(URL_FOUND 0 CACHE INTERNAL "URL not found")
  endif()
endfunction()

# Download PHP tarball.
if(NOT EXISTS ${_php_tarball})
  message(STATUS "Downloading PHP ${PHP_VERSION}")

  check_url(${_download_url})

  if(NOT URL_FOUND)
    message(FATAL_ERROR "URL ${_download_url} returned error")
  endif()

  file(DOWNLOAD ${_download_url} ${_php_tarball} SHOW_PROGRESS)
endif()

file(ARCHIVE_EXTRACT INPUT ${_php_tarball})

if(EXISTS php-src-master)
  file(RENAME php-src-master ${_php_directory})
endif()

# Add CMake files.
file(INSTALL cmake/ DESTINATION ${_php_directory})

# Apply patches for php-src.
file(GLOB_RECURSE patches "patches/*.patch")

# Check if git command is available.
find_program(GIT_EXECUTABLE git)

if(NOT GIT_EXECUTABLE)
  message(FATAL_ERROR "Git executable not found. Cannot apply patches for PHP source code.")
endif()

# Add .git directory to be able to apply patches.
execute_process(
  COMMAND ${GIT_EXECUTABLE} init
  WORKING_DIRECTORY ${_php_directory}
  RESULT_VARIABLE _result
  OUTPUT_VARIABLE _output
  ERROR_VARIABLE _error
  ERROR_STRIP_TRAILING_WHITESPACE
  OUTPUT_QUIET
)

if(NOT _result EQUAL 0)
  message(FATAL_ERROR "${_output}\n${_error}")
endif()

# Define the command to apply the patches using git.
set(_patch_command ${GIT_EXECUTABLE} apply --ignore-whitespace)

foreach(patch ${patches})
  # Execute the patch command.
  execute_process(
    COMMAND ${_patch_command} "${patch}"
    WORKING_DIRECTORY ${_php_directory}
    RESULT_VARIABLE _patch_result
  )

  cmake_path(GET patch FILENAME _patch_filename)

  if(_patch_result EQUAL 0)
    message(STATUS "Patch ${_patch_filename} applied successfully.")
  else()
    message(WARNING "Failed to apply patch ${_patch_filename}.")
  endif()
endforeach()

# Patch PHP version in main CMakeLists.txt file to match the one downloaded.
message(STATUS "Patching version in ${_php_directory}/CMakeLists.txt")

string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)([a-zA-Z0-9\\-]*)$" _ ${PHP_VERSION})

set(PHP_VERSION_MAJOR ${CMAKE_MATCH_1})
set(PHP_VERSION_MINOR ${CMAKE_MATCH_2})
set(PHP_VERSION_PATCH ${CMAKE_MATCH_3})
set(PHP_VERSION_LABEL ${CMAKE_MATCH_4})

string(CONCAT PHP_VERSION_MAIN "${PHP_VERSION_MAJOR}" "." "${PHP_VERSION_MINOR}" "." "${PHP_VERSION_PATCH}")

file(READ "${_php_directory}/CMakeLists.txt" _file_contents)
string(REPLACE "VERSION 8.3.0" "VERSION ${PHP_VERSION_MAIN}" _file_contents "${_file_contents}")
string(REPLACE "set(PHP_VERSION_LABEL \"-dev\"" "set(PHP_VERSION_LABEL \"${PHP_VERSION_LABEL}\"" _file_contents ${_file_contents})
file(WRITE "${_php_directory}/CMakeLists.txt" "${_file_contents}")

message("
${_php_directory} directory is now ready to use")
