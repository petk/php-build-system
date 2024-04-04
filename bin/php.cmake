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

    PHP version to download: MAJOR.MINOR[.PATCH][EXTRA]

Usage examples:
  Download latest stable release from php.net:
    cmake -P bin/php.cmake 8.3

  Download specific version from php.net:
    cmake -P bin/php.cmake 8.3.0RC6

  Or:
    ./bin/php.cmake 8.3.0RC6

  Download the current Git PHP-8.3 branch:
    ./bin/php.cmake 8.3-dev

  Download the current Git master branch:
    ./bin/php.cmake
#]=============================================================================]

cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

################################################################################
# Set default variables.
################################################################################

# The MAJOR.MINOR version currently in development.
set(PHP_VERSION_DEV "8.4")
# The latest stable PHP version as a fallback when version cannot be discovered
# from remote JSON output.
set(PHP_VERSION_FALLBACK "8.3.4")

# Set PHP version.
if(CMAKE_ARGV3)
  set(PHP_VERSION "${CMAKE_ARGV3}")
else()
  set(PHP_VERSION "${PHP_VERSION_DEV}-dev")
endif()

# Get latest PHP stable version from JSON API.
if(
  PHP_VERSION MATCHES [[^[0-9]+\.[0-9]+$]]
  AND NOT PHP_VERSION STREQUAL "${PHP_VERSION_DEV}"
)
  block(PROPAGATE PHP_VERSION)
    string(TIMESTAMP t)
    set(file ".release-${t}.json")
    file(DOWNLOAD "https://www.php.net/releases/index.php?json" "${file}")
    file(READ "${file}" json)
    file(REMOVE "${file}")

    string(
      JSON
      filename
      ERROR_VARIABLE error
      GET "${json}"
      8 source 0 filename
    )

    if(error)
      message(
        WARNING
        "Could not determine latest PHP version from remote JSON."
        "Using ${PHP_VERSION_FALLBACK}."
        "Error: ${error}"
      )
      set(PHP_VERSION "${PHP_VERSION_FALLBACK}")
    else()
      string(REGEX MATCH [[php-([0-9]+.[0-9]+.[0-9]+).tar.gz]] _ "${filename}")
      set(PHP_VERSION "${CMAKE_MATCH_1}")
    endif()
  endblock()
endif()

# Set working paths.
cmake_path(SET PHP_ROOT_DIR NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/..")
cmake_path(SET PHP_SOURCE_DIR NORMALIZE "${PHP_ROOT_DIR}/php-${PHP_VERSION}")
cmake_path(
  SET
  PHP_TARBALL
  NORMALIZE
  "${PHP_ROOT_DIR}/php-${PHP_VERSION}.tar.gz"
)
cmake_path(
  RELATIVE_PATH
  PHP_ROOT_DIR
  BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  OUTPUT_VARIABLE PHP_ROOT_DIR_RELATIVE
)
cmake_path(
  RELATIVE_PATH
  PHP_SOURCE_DIR
  BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  OUTPUT_VARIABLE PHP_SOURCE_DIR_RELATIVE
)
cmake_path(
  NATIVE_PATH
  PHP_SOURCE_DIR_RELATIVE
  NORMALIZE
  PHP_SOURCE_DIR_RELATIVE
)

################################################################################
# Check requirements.
################################################################################

# Check PHP version.
if(
  NOT PHP_VERSION MATCHES [[^[0-9]+\.[0-9]+\.[0-9]+[a-zA-Z0-9-]*$]]
  AND NOT PHP_VERSION MATCHES [[^[0-9]+\.[0-9]+-dev$]]
)
  message(
    FATAL_ERROR
    "PHP version should match pattern MAJOR.MINOR[.PATCH][EXTRA]"
  )
elseif(
  PHP_VERSION VERSION_LESS 8.3.0
  OR PHP_VERSION VERSION_GREATER "${PHP_VERSION_DEV}"
)
  message(FATAL_ERROR "Unsupported PHP version.")
endif()

# Check if source directory exists.
if(EXISTS "${PHP_SOURCE_DIR}")
  message(
    FATAL_ERROR
    "To continue, please remove existing directory ${PHP_SOURCE_DIR_RELATIVE}"
  )
endif()

# Check if curl or wget is available.
find_program(DOWNLOAD_TOOL curl)

if(DOWNLOAD_TOOL)
  set(DOWNLOAD_TOOL ${DOWNLOAD_TOOL} --silent --head --fail)
else()
  find_program(DOWNLOAD_TOOL wget)

  if(DOWNLOAD_TOOL)
    set(DOWNLOAD_TOOL ${DOWNLOAD_TOOL} --quiet --method=HEAD)
  endif()
endif()

if(NOT DOWNLOAD_TOOL)
  message(FATAL_ERROR "Please install curl or wget.")
endif()

# Check if git command is available.
find_program(GIT_EXECUTABLE git)

if(NOT GIT_EXECUTABLE)
  message(FATAL_ERROR "Git not found. Please install Git: https://git-scm.com")
endif()

################################################################################
# Functions.
################################################################################

# Helper that checks if given URL is found.
function(php_check_url url result)
  execute_process(
    COMMAND ${DOWNLOAD_TOOL} ${url}
    RESULT_VARIABLE status
    OUTPUT_QUIET
  )

  if(status EQUAL 0)
    set(${result} 1)
  else()
    set(${result} 0)
  endif()

  return(PROPAGATE ${result})
endfunction()

# Helper that downloads PHP sources.
function(php_download)
  # Determine the download URL.
  if(
    PHP_VERSION STREQUAL "${PHP_VERSION_DEV}"
    OR PHP_VERSION MATCHES "${PHP_VERSION_DEV}-dev"
  )
    set(branch "master")

    list(
      APPEND
      urls
      "https://github.com/php/php-src/archive/refs/heads/${branch}.tar.gz"
    )
  elseif(PHP_VERSION MATCHES "^.*-dev$")
    string(REGEX MATCH [[(^[0-9]+)\.([0-9]+).*$]] _ "${PHP_VERSION}")
    set(branch "PHP-${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")

    list(
      APPEND
      urls
      "https://github.com/php/php-src/archive/refs/heads/${branch}.tar.gz"
    )
  else()
    list(
      APPEND
      urls
      "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz"
    )
    list(
      APPEND
      urls
      "https://downloads.php.net/~eric/php-${PHP_VERSION}.tar.gz"
    )
    list(
      APPEND
      urls
      "https://downloads.php.net/~jakub/php-${PHP_VERSION}.tar.gz"
    )
  endif()

  # Download PHP tarball.
  if(NOT EXISTS ${PHP_TARBALL})
    foreach(url ${urls})
      php_check_url(${url} found)

      if(found)
        set(downloadUrl ${url})
        break()
      endif()
    endforeach()

    if(NOT downloadUrl)
      message(
        FATAL_ERROR
        "Download URL for PHP ${PHP_VERSION} could not be found"
      )
    endif()

    message(STATUS "Downloading PHP ${PHP_VERSION}")

    file(DOWNLOAD ${downloadUrl} ${PHP_TARBALL} SHOW_PROGRESS)
  endif()

  message("")
  message(STATUS "Extracting ${PHP_TARBALL}")
  file(ARCHIVE_EXTRACT
    INPUT ${PHP_TARBALL}
    DESTINATION ${PHP_ROOT_DIR}
  )

  if(EXISTS ${PHP_ROOT_DIR}/php-src-${branch})
    file(RENAME ${PHP_ROOT_DIR}/php-src-${branch} ${PHP_SOURCE_DIR})
  endif()
endfunction()

# Helper that prepares PHP sources for using CMake.
function(php_prepare_sources)
  php_download()

  # Add CMake files.
  message("")
  message(STATUS "Adding CMake source files to ${PHP_SOURCE_DIR_RELATIVE}")
  file(INSTALL ${PHP_ROOT_DIR}/cmake/ DESTINATION ${PHP_SOURCE_DIR})

  # Add .git directory to be able to apply patches.
  execute_process(
    COMMAND ${GIT_EXECUTABLE} init
    WORKING_DIRECTORY ${PHP_SOURCE_DIR}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    ERROR_STRIP_TRAILING_WHITESPACE
    OUTPUT_QUIET
  )

  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Could not add .git directory:\n${output}\n${error}")
  endif()

  message("")
  message(STATUS "Applying patches to ${PHP_SOURCE_DIR_RELATIVE}")

  # Apply patches for php-src.
  string(REGEX MATCH [[([0-9]+\.[0-9]+).*$]] _ "${PHP_VERSION}")
  file(GLOB_RECURSE patches ${PHP_ROOT_DIR}/patches/${CMAKE_MATCH_1}/*.patch)

  foreach(patch ${patches})
    # Execute the patch command.
    execute_process(
      COMMAND ${GIT_EXECUTABLE} apply --ignore-whitespace "${patch}"
      WORKING_DIRECTORY ${PHP_SOURCE_DIR}
      RESULT_VARIABLE result
    )

    cmake_path(GET patch FILENAME filename)

    if(result EQUAL 0)
      message(STATUS "Patch ${filename} applied successfully.")
    else()
      message(WARNING "Failed to apply patch ${filename}.")
    endif()
  endforeach()

  # Clean temporary .git directory. Checks are done as safeguards.
  if(
    PHP_SOURCE_DIR MATCHES "\\/php-8\\.[0-9][.-].*$"
    AND IS_DIRECTORY ${PHP_SOURCE_DIR}/.git/
    AND EXISTS ${PHP_SOURCE_DIR}/php.ini-development
    AND EXISTS ${PHP_SOURCE_DIR}/main/php_version.h
    AND EXISTS ${PHP_SOURCE_DIR}/CMakeLists.txt
  )
    file(REMOVE_RECURSE ${PHP_SOURCE_DIR}/.git/)
  endif()
endfunction()

# Helper that starts the script.
function(php_init)
  php_prepare_sources()

  set(buildDir ${PHP_ROOT_DIR_RELATIVE}/php-build)
  cmake_path(NATIVE_PATH buildDir NORMALIZE buildDir)

  message("
  The ${PHP_SOURCE_DIR_RELATIVE} directory is now ready to use. For example:

    cmake -S ${PHP_SOURCE_DIR_RELATIVE} -B ${buildDir}
    cmake --build ${buildDir} -j
  ")
endfunction()

################################################################################
# Scrip initialization.
################################################################################

php_init()
