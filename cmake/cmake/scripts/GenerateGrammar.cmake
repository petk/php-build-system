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
#
# TODO: Should the Bison-generated report files (*.output) really be also
# created by this script (the `VERBOSE REPORT_FILE <file>` options)? PHP still
# packages these reports also in the archive release files?! Also, ext/json
# doesn't produce the *.output file.

cmake_minimum_required(VERSION 3.25...3.31)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

set(PHP_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

if(NOT EXISTS ${PHP_SOURCE_DIR}/main/php_version.h)
  message(FATAL_ERROR "This script should be run in the php-src repository.")
endif()

list(APPEND CMAKE_MODULE_PATH ${PHP_SOURCE_DIR}/cmake/modules)

include(PHP/BISON)
include(PHP/RE2C)

include(FeatureSummary)
feature_summary(
  FATAL_ON_MISSING_REQUIRED_PACKAGES
  WHAT REQUIRED_PACKAGES_NOT_FOUND
  QUIET_ON_EMPTY
  DEFAULT_DESCRIPTION
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
  include(${script})
endforeach()
