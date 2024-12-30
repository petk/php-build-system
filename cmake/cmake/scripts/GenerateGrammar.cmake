#!/usr/bin/env -S cmake -P
#
# CMake-based command-line script to generate the parser files using bison and
# lexer files using bison.
#
# Run as:
#
#   cmake -P cmake/scripts/GenerateGrammar.cmake
#
# To manually override bison and re2c executables:
#
#   cmake \
#     [-D BISON_EXECUTABLE=path/to/bison] \
#     [-D RE2C_EXECUTABLE=path/to/re2c] \
#     -P cmake/scripts/GenerateGrammar.cmake

cmake_minimum_required(VERSION 3.25...3.31)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

set(PHP_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

if(NOT EXISTS ${PHP_SOURCE_DIR}/main/php_version.h)
  message(FATAL_ERROR "This script should be run in the php-src repository.")
endif()

list(APPEND CMAKE_MODULE_PATH ${PHP_SOURCE_DIR}/cmake/modules)

include(FeatureSummary)

include(PHP/Package/BISON)
set_package_properties(BISON PROPERTIES TYPE REQUIRED)

include(PHP/Package/RE2C)
set_package_properties(RE2C PROPERTIES TYPE REQUIRED)

feature_summary(
  DEFAULT_DESCRIPTION
  FATAL_ON_MISSING_REQUIRED_PACKAGES
  QUIET_ON_EMPTY
  WHAT REQUIRED_PACKAGES_NOT_FOUND
)

file(
  GLOB_RECURSE scripts
  ${PHP_SOURCE_DIR}/*/*/cmake/GenerateGrammar.cmake
  ${PHP_SOURCE_DIR}/*/cmake/GenerateGrammar.cmake
)
foreach(script IN LISTS scripts)
  cmake_path(GET script PARENT_PATH path)
  cmake_path(GET path PARENT_PATH path)
  set(CMAKE_CURRENT_SOURCE_DIR ${path})
  set(CMAKE_CURRENT_BINARY_DIR ${path})

  cmake_path(
    RELATIVE_PATH
    path
    BASE_DIRECTORY ${PHP_SOURCE_DIR}
    OUTPUT_VARIABLE relativeDir
  )
  message(STATUS "Processing ${relativeDir} files")

  include(${script})
endforeach()
