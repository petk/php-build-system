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
  Downloads specific version from php.net:
    cmake -P bin/php.cmake 8.3.0RC2

  Or:
    ./bin/php.cmake 8.3.0RC2

  Downloads the current Git PHP-8.3 branch:
    ./bin/php.cmake 8.3-dev

  Downloads the current Git master branch:
    ./bin/php.cmake 8.4-dev
#]=============================================================================]

# Helper that checks if given URL is found.
function(check_url)
  unset(URL_FOUND CACHE)

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

# Set default variables.
set(PHP_VERSION "8.4-dev")

if(CMAKE_ARGV3)
  set(PHP_VERSION "${CMAKE_ARGV3}")
endif()

if(
  NOT PHP_VERSION MATCHES "^8\\.[0-9]\\.[0-9]+[a-zA-Z0-9\\-]*$"
  AND NOT PHP_VERSION MATCHES "^8\\.[0-9]-dev$"
)
  message(FATAL_ERROR "PHP version should match pattern {MAJOR}.{MINOR}.{PATCH}{EXTRA}")
endif()

if(
  PHP_VERSION MATCHES "^8\\.[0-2].*$"
)
  message(FATAL_ERROR "Only PHP 8.3 or greater is supported.")
endif()

set(_php_directory "php-${PHP_VERSION}")

if(EXISTS "${_php_directory}")
  message(FATAL_ERROR "To continue, please remove previous existing directory ${_php_directory}")
endif()

# Determine the download URL.
if(PHP_VERSION MATCHES "8.4-dev")
  set(_php_branch "master")

  list(APPEND _urls "https://github.com/php/php-src/archive/refs/heads/${_php_branch}.tar.gz")
elseif(PHP_VERSION MATCHES "^.*-dev$")
  string(REGEX MATCH "([0-9]+)\\.([0-9]+).*$" _ ${PHP_VERSION})

  set(_php_branch "PHP-${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
  message(STATUS "Status: ${_php_branch}")

  list(APPEND _urls "https://github.com/php/php-src/archive/refs/heads/${_php_branch}.tar.gz")
else()
  list(APPEND _urls "https://downloads.php.net/~eric/php-${PHP_VERSION}.tar.gz")
  list(APPEND _urls "https://downloads.php.net/~jakub/php-${PHP_VERSION}.tar.gz")
  list(APPEND _urls "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz")
endif()

# Download PHP tarball.
set(_php_tarball "php-${PHP_VERSION}.tar.gz")

if(NOT EXISTS ${_php_tarball})
  foreach(url ${_urls})
    check_url(${url})

    if(URL_FOUND)
      set(_download_url ${url})
      break()
    endif()
  endforeach()

  if(NOT _download_url)
    message(FATAL_ERROR "Download URL for PHP ${PHP_VERSION} could not be found")
  endif()

  message(STATUS "Downloading PHP ${PHP_VERSION}")

  file(DOWNLOAD ${_download_url} ${_php_tarball} SHOW_PROGRESS TLS_VERIFY ON)
endif()

# Check if git command is available.
find_program(GIT_EXECUTABLE git)

if(NOT GIT_EXECUTABLE)
  message(FATAL_ERROR "Git executable not found. Cannot apply patches for PHP source code.")
endif()

message("")
message(STATUS "Extracting ${_php_tarball}")
file(ARCHIVE_EXTRACT INPUT ${_php_tarball})

if(EXISTS php-src-${_php_branch})
  file(RENAME php-src-${_php_branch} ${_php_directory})
endif()

# Add CMake files.
message("")
message(STATUS "Adding CMake source files to ${_php_directory}")
file(INSTALL cmake/ DESTINATION ${_php_directory})

# Apply patches for php-src.
string(REGEX MATCH "([0-9]+\\.[0-9]+).*$" _ ${PHP_VERSION})
file(GLOB_RECURSE patches "patches/${CMAKE_MATCH_1}/*.patch")

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

message("")
message(STATUS "Applying patches to ${_php_directory}")

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

# Clean temporary .git directory. Checks are done as safeguards.
if(
  _php_directory MATCHES "php-8\\.[0-9][\\.-].*"
  AND IS_DIRECTORY ${_php_directory}/.git/
  AND EXISTS ${_php_directory}/php.ini-development
  AND EXISTS ${_php_directory}/main/php_version.h
  AND EXISTS ${_php_directory}/CMakeLists.txt
)
  file(REMOVE_RECURSE ${_php_directory}/.git/)
endif()

message("")
message("${_php_directory} directory is now ready to use.

For example:
  cd ${_php_directory}
  cmake .
  cmake --build . -- -j$(nproc)
")
