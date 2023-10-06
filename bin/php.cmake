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
    cmake -P bin/php.cmake 8.3.0RC3

  Or:
    ./bin/php.cmake 8.3.0RC3

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

cmake_path(SET PHP_ROOT_DIR NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/..")
cmake_path(SET PHP_SOURCE_DIR NORMALIZE "${PHP_ROOT_DIR}/php-${PHP_VERSION}")
set(PHP_SOURCE_RELATIVE_DIR "php-${PHP_VERSION}")

if(EXISTS "${PHP_SOURCE_DIR}")
  message(FATAL_ERROR "To continue, please remove previous existing directory ${PHP_SOURCE_RELATIVE_DIR}")
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
set(_php_tarball "${PHP_ROOT_DIR}/php-${PHP_VERSION}.tar.gz")

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

  file(DOWNLOAD ${_download_url} ${_php_tarball} SHOW_PROGRESS)
endif()

# Check if git command is available.
find_program(GIT_EXECUTABLE git)

if(NOT GIT_EXECUTABLE)
  message(FATAL_ERROR "Git executable not found. Cannot apply patches for PHP source code.")
endif()

message("")
message(STATUS "Extracting ${_php_tarball}")
file(ARCHIVE_EXTRACT
  INPUT ${_php_tarball}
  DESTINATION ${PHP_ROOT_DIR}
)

if(EXISTS ${PHP_ROOT_DIR}/php-src-${_php_branch})
  file(RENAME ${PHP_ROOT_DIR}/php-src-${_php_branch} ${PHP_SOURCE_DIR})
endif()

# Add CMake files.
message("")
message(STATUS "Adding CMake source files to ${PHP_SOURCE_RELATIVE_DIR}")
file(INSTALL ${PHP_ROOT_DIR}/cmake/ DESTINATION ${PHP_SOURCE_DIR})

# Apply patches for php-src.
string(REGEX MATCH "([0-9]+\\.[0-9]+).*$" _ ${PHP_VERSION})
file(GLOB_RECURSE patches "${PHP_ROOT_DIR}/patches/${CMAKE_MATCH_1}/*.patch")

# Add .git directory to be able to apply patches.
execute_process(
  COMMAND ${GIT_EXECUTABLE} init
  WORKING_DIRECTORY ${PHP_SOURCE_DIR}
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
message(STATUS "Applying patches to ${PHP_SOURCE_RELATIVE_DIR}")

# Define the command to apply the patches using git.
set(_patch_command ${GIT_EXECUTABLE} apply --ignore-whitespace)

foreach(patch ${patches})
  # Execute the patch command.
  execute_process(
    COMMAND ${_patch_command} "${patch}"
    WORKING_DIRECTORY ${PHP_SOURCE_DIR}
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
  PHP_SOURCE_DIR MATCHES "\\/php-8\\.[0-9][\\.-].*$"
  AND IS_DIRECTORY ${PHP_SOURCE_DIR}/.git/
  AND EXISTS ${PHP_SOURCE_DIR}/php.ini-development
  AND EXISTS ${PHP_SOURCE_DIR}/main/php_version.h
  AND EXISTS ${PHP_SOURCE_DIR}/CMakeLists.txt
)
  file(REMOVE_RECURSE ${PHP_SOURCE_DIR}/.git/)
endif()

message("")
message("${PHP_SOURCE_RELATIVE_DIR} directory is now ready to use.

For example:
  mkdir my-php-build
  cd my-php-build
  cmake ../path/to/${PHP_SOURCE_RELATIVE_DIR}
  cmake --build . -j
")
