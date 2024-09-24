#!/usr/bin/env -S cmake -P
#
#[=============================================================================[
PHP CMake initialization helper

This helper script copies CMake files from the cmake directory to the cloned
php-src Git repository and applies patches from the patches directory to use
CMake.

SYNOPSIS:
  bin/init.cmake [<options>]

Usage:
  cmake -P bin/init.cmake
#]=============================================================================]

cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# The PHP MAJOR.MINOR version currently in development (the master branch).
set(PHP_DEVELOPMENT_VERSION "8.5")

# Check if git command is available.
find_program(GIT_EXECUTABLE git DOC "Path to the Git executable")

if(NOT GIT_EXECUTABLE)
  message(FATAL_ERROR "Git not found. Please install Git: https://git-scm.com")
endif()

cmake_path(GET CMAKE_CURRENT_LIST_DIR PARENT_PATH PHP_ROOT_DIR)
set(PHP_SRC_DIR ${PHP_ROOT_DIR}/php-src)

# Clone a fresh latest php-src repository.
if(NOT IS_DIRECTORY ${PHP_SRC_DIR})
  message(
    FATAL_ERROR
    "To use this tool you need php-src Git repository. Inside the "
    "php-build-system Git repository run:\n"
    "  git clone https://github.com/php/php-src"
  )
endif()

# Determine PHP branch from the current php-build-system repository branch.
execute_process(
  COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
  WORKING_DIRECTORY ${PHP_ROOT_DIR}
  OUTPUT_VARIABLE GIT_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT GIT_BRANCH MATCHES "^PHP-[0-9]+\.[0-9]+$")
  set(GIT_BRANCH "master")
endif()

# Make sure the cloned php-src repository is the correct php-src repository.
if(
  NOT EXISTS ${PHP_SRC_DIR}/main/php_version.h
  OR NOT EXISTS ${PHP_SRC_DIR}/php.ini-development
)
  message(FATAL_ERROR "The php-src doesn't seem to be Git repository.")
endif()

# Check if given branch is available.
execute_process(
  COMMAND ${GIT_EXECUTABLE} show-ref refs/heads/${GIT_BRANCH}
  WORKING_DIRECTORY ${PHP_SRC_DIR}
  OUTPUT_VARIABLE GIT_REF
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT GIT_REF)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-remote --heads origin refs/heads/${GIT_BRANCH}
    WORKING_DIRECTORY ${PHP_SRC_DIR}
    OUTPUT_VARIABLE GIT_REMOTE_HEADS
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(NOT GIT_REMOTE_HEADS)
    message(FATAL_ERROR "PHP branch ${GIT_BRANCH} doesn't exist")
  endif()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} checkout --track origin/${GIT_BRANCH}
    WORKING_DIRECTORY ${PHP_SRC_DIR}
  )
endif()

# Reset php-src repository and fetch latest changes.
execute_process(
  COMMAND ${GIT_EXECUTABLE} reset --hard
  WORKING_DIRECTORY ${PHP_SRC_DIR}
)
execute_process(
  COMMAND ${GIT_EXECUTABLE} clean -dffx
  WORKING_DIRECTORY ${PHP_SRC_DIR}
)
execute_process(
  COMMAND ${GIT_EXECUTABLE} checkout ${GIT_BRANCH}
  WORKING_DIRECTORY ${PHP_SRC_DIR}
)
execute_process(
  COMMAND ${GIT_EXECUTABLE} pull --rebase
  WORKING_DIRECTORY ${PHP_SRC_DIR}
)

# Add CMake files.
message("")
message(STATUS "Adding CMake source files to ${PHP_SRC_DIR}")
file(INSTALL ${PHP_ROOT_DIR}/cmake/ DESTINATION ${PHP_SRC_DIR})

message("")
message(STATUS "Applying patches to ${PHP_SOURCE_DIR_NAME}")

# Apply patches for php-src.
if(GIT_BRANCH STREQUAL "master")
  set(PHP_VERSION "${PHP_DEVELOPMENT_VERSION}")
else()
  string(REGEX MATCH [[([0-9]+\.[0-9]+).*$]] PHP_VERSION "${GIT_BRANCH}")
endif()

file(GLOB_RECURSE patches ${PHP_ROOT_DIR}/patches/${PHP_VERSION}/*.patch)

foreach(patch ${patches})
  # Apply the patch with Git.
  execute_process(
    COMMAND ${GIT_EXECUTABLE} apply --ignore-whitespace "${patch}"
    WORKING_DIRECTORY ${PHP_SRC_DIR}
    RESULT_VARIABLE patchResult
  )

  cmake_path(GET patch FILENAME patchFilename)

  if(patchResult EQUAL 0)
    message(STATUS "Patch ${patchFilename} applied successfully.")
  else()
    message(WARNING "Failed to apply patch ${patchFilename}.")
  endif()
endforeach()

message([[

PHP sources are ready. Inside the php-src, you can now run CMake commands.
For example:

  cmake -S php-src -B php-src/php-build
  cmake --build php-src/php-build --parallel
  php-src/php-build/sapi/cli/php -v
]])
