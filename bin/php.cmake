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
    cmake -P bin/php.cmake 8.3.0RC4

  Or:
    ./bin/php.cmake 8.3.0RC4

  Downloads the current Git PHP-8.3 branch:
    ./bin/php.cmake 8.3-dev

  Downloads the current Git master branch:
    ./bin/php.cmake 8.4-dev
#]=============================================================================]

################################################################################
# Set default variables.
################################################################################

# Set PHP version.
if(CMAKE_ARGV3)
  set(PHP_VERSION "${CMAKE_ARGV3}")
else()
  set(PHP_VERSION "8.4-dev")
endif()

# Set working paths.
cmake_path(SET PHP_ROOT_DIR NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/..")
cmake_path(SET PHP_SOURCE_DIR NORMALIZE "${PHP_ROOT_DIR}/php-${PHP_VERSION}")
cmake_path(SET PHP_TARBALL NORMALIZE "${PHP_ROOT_DIR}/php-${PHP_VERSION}.tar.gz")
set(PHP_SOURCE_DIR_NAME "php-${PHP_VERSION}")

################################################################################
# Check requirements.
################################################################################

# Check PHP version.
if(
  NOT PHP_VERSION MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+[a-zA-Z0-9\\-]*$"
  AND NOT PHP_VERSION MATCHES "^[0-9]+\\.[0-9]+-dev$"
)
  message(FATAL_ERROR "PHP version should match pattern {MAJOR}.{MINOR}.{PATCH}{EXTRA}")
elseif(PHP_VERSION VERSION_LESS "8.3.0" OR PHP_VERSION VERSION_GREATER "8.4")
  message(FATAL_ERROR "Unsupported PHP version.")
endif()

# Check if source directory exists.
if(EXISTS "${PHP_SOURCE_DIR}")
  message(FATAL_ERROR "To continue, please remove existing directory ${PHP_SOURCE_DIR_NAME}")
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
  message(FATAL_ERROR "Git not found. Please install Git.")
endif()

################################################################################
# Functions.
################################################################################

# Helper that checks if given URL is found.
function(php_check_url url)
  execute_process(
    COMMAND ${DOWNLOAD_TOOL} ${url}
    RESULT_VARIABLE URL_FOUND
    OUTPUT_QUIET
  )

  if(URL_FOUND EQUAL 0)
    set(URL_FOUND 1 PARENT_SCOPE)
  else()
    set(URL_FOUND 0 PARENT_SCOPE)
  endif()
endfunction()

# Helper that downloads PHP sources.
function(php_download)
  # Determine the download URL.
  if(PHP_VERSION MATCHES "8.4-dev")
    set(php_branch "master")

    list(APPEND urls "https://github.com/php/php-src/archive/refs/heads/${php_branch}.tar.gz")
  elseif(PHP_VERSION MATCHES "^.*-dev$")
    string(REGEX MATCH "(^[0-9]+)\\.([0-9]+).*$" _ ${PHP_VERSION})
    set(php_branch "PHP-${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")

    list(APPEND urls "https://github.com/php/php-src/archive/refs/heads/${php_branch}.tar.gz")
  else()
    list(APPEND urls "https://downloads.php.net/~eric/php-${PHP_VERSION}.tar.gz")
    list(APPEND urls "https://downloads.php.net/~jakub/php-${PHP_VERSION}.tar.gz")
    list(APPEND urls "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz")
  endif()

  # Download PHP tarball.
  if(NOT EXISTS ${PHP_TARBALL})
    foreach(url ${urls})
      php_check_url(${url})

      if(URL_FOUND)
        set(download_url ${url})
        break()
      endif()
    endforeach()

    if(NOT download_url)
      message(FATAL_ERROR "Download URL for PHP ${PHP_VERSION} could not be found")
    endif()

    message(STATUS "Downloading PHP ${PHP_VERSION}")

    file(DOWNLOAD ${download_url} ${PHP_TARBALL} SHOW_PROGRESS)
  endif()

  message("")
  message(STATUS "Extracting ${PHP_TARBALL}")
  file(ARCHIVE_EXTRACT
    INPUT ${PHP_TARBALL}
    DESTINATION ${PHP_ROOT_DIR}
  )

  if(EXISTS ${PHP_ROOT_DIR}/php-src-${php_branch})
    file(RENAME ${PHP_ROOT_DIR}/php-src-${php_branch} ${PHP_SOURCE_DIR})
  endif()
endfunction()

# Helper that prepares PHP sources for using CMake.
function(php_prepare_sources)
  php_download()

  # Add CMake files.
  message("")
  message(STATUS "Adding CMake source files to ${PHP_SOURCE_DIR_NAME}")
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
  message(STATUS "Applying patches to ${PHP_SOURCE_DIR_NAME}")

  # Apply patches for php-src.
  string(REGEX MATCH "([0-9]+\\.[0-9]+).*$" _ ${PHP_VERSION})
  file(GLOB_RECURSE patches "${PHP_ROOT_DIR}/patches/${CMAKE_MATCH_1}/*.patch")

  foreach(patch ${patches})
    # Execute the patch command.
    execute_process(
      COMMAND ${GIT_EXECUTABLE} apply --ignore-whitespace "${patch}"
      WORKING_DIRECTORY ${PHP_SOURCE_DIR}
      RESULT_VARIABLE patch_result
    )

    cmake_path(GET patch FILENAME patch_filename)

    if(patch_result EQUAL 0)
      message(STATUS "Patch ${patch_filename} applied successfully.")
    else()
      message(WARNING "Failed to apply patch ${patch_filename}.")
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
endfunction()

# Helper that starts the script.
function(php_init)
  php_prepare_sources()

  message("")
  message("${PHP_SOURCE_DIR_NAME} directory is now ready to use.
  For example:
    mkdir my-php-build
    cd my-php-build
    cmake ../path/to/${PHP_SOURCE_DIR_NAME}
    cmake --build . -j
  ")
endfunction()

################################################################################
# Scrip initialization.
################################################################################

php_init()
