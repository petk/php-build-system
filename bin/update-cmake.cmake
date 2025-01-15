#!/usr/bin/env -S cmake -P
#
# Update the minimum required CMake version.
#
# Run as:
#
#   cmake [-D DIR=<path>] -P bin/update-cmake.cmake
#
#   DIR - path to the directory containing CMake files.
#
# This is CMake-based command-line script that updates cmake_minimum_required()
# calls in all found CMake files with the cmake_minimum_required() as specified
# in this file (see the first line of the code below).

cmake_minimum_required(VERSION 3.25...3.31)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

if(NOT DIR)
  cmake_path(SET DIR NORMALIZE ${CMAKE_CURRENT_LIST_DIR}/../cmake)
else()
  cmake_path(
    ABSOLUTE_PATH
    DIR
    BASE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
    NORMALIZE
  )
endif()

if(NOT IS_DIRECTORY ${DIR})
  message(FATAL_ERROR "Directory not found: ${DIR}")
endif()

string(
  CONCAT regex
  "cmake_minimum_required"
  "[ \t]*"
  "\\("
  "[ \t\r\n]*"
  "VERSION"
  "[ \t\r\n]+"
  "[0-9]\\.[0-9]+[0-9.]*"
  "(\\.\\.\\.[0-9]\\.[0-9]+)?"
  "[ \t\r\n]*"
  "(FATAL_ERROR)?"
  "[ \t\r\n]*"
  "\\)"
)

# Get CMake minimum required version specification from this script.
file(STRINGS ${CMAKE_CURRENT_LIST_FILE} update REGEX "^${regex}" LIMIT_COUNT 1)
message(STATUS "Using: ${update}")

message(STATUS "Checking CMake files in ${DIR}")

file(
  GLOB_RECURSE files
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  ${DIR}/CMakeLists.txt
  ${DIR}/CMakeLists.txt.in
  ${DIR}/*.cmake
  ${DIR}/*.cmake.in
)

foreach(file IN LISTS files)
  file(READ ${file} content)

  if(NOT content MATCHES "${regex}")
    continue()
  endif()

  string(REGEX REPLACE "${regex}" "${update}" newContent "${content}")

  if(newContent STREQUAL "${content}")
    continue()
  endif()

  message(STATUS "Updating ${file}")
  file(WRITE ${file} "${newContent}")
endforeach()
