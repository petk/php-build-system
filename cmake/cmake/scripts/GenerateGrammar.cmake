#!/usr/bin/env -S cmake -P
#
# CMake-based command-line script to generate the parser files using bison and
# lexer files using bison.
#
# Run as:
#
#   cmake -P cmake/scripts/GenerateLexersParsers.cmake
#
# To manually override bison and re2c executables:
#
#   cmake \
#     [-D BISON_EXECUTABLE=path/to/bison] \
#     [-D RE2C_EXECUTABLE=path/to/re2c] \
#     -P cmake/scripts/GenerateLexersParsers.cmake
#
# TODO: Fix CS and fine tune this.
#
# TODO: Should the Bison-generated report files (*.output) really be also
# created by this script (the `VERBOSE REPORT_FILE <file>` options)? PHP still
# packages these reports also in the archive release files?! Also, ext/json
# doesn't produce the *.output file.
#
# TODO: Add remaining missing features to FindBISON.cmake module.

cmake_minimum_required(VERSION 3.25...3.31)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

set(PHP_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

if(NOT EXISTS ${PHP_SOURCE_DIR}/main/php_version.h)
  message(FATAL_ERROR "This script should be run inside the php-src repository")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../modules)

include(PHP/BISON)
include(PHP/RE2C)

include(FeatureSummary)
feature_summary(
  FATAL_ON_MISSING_REQUIRED_PACKAGES
  WHAT REQUIRED_PACKAGES_NOT_FOUND
  QUIET_ON_EMPTY
  DEFAULT_DESCRIPTION
)

set(CMAKE_CURRENT_SOURCE_DIR ${PHP_SOURCE_DIR}/ext/json)
set(CMAKE_CURRENT_BINARY_DIR ${PHP_SOURCE_DIR}/ext/json)
include(${PHP_SOURCE_DIR}/ext/json/cmake/GenerateGrammar.cmake)

set(CMAKE_CURRENT_SOURCE_DIR ${PHP_SOURCE_DIR}/ext/pdo)
set(CMAKE_CURRENT_BINARY_DIR ${PHP_SOURCE_DIR}/ext/pdo)
include(${PHP_SOURCE_DIR}/ext/pdo/cmake/GenerateGrammar.cmake)

set(CMAKE_CURRENT_SOURCE_DIR ${PHP_SOURCE_DIR}/ext/phar)
set(CMAKE_CURRENT_BINARY_DIR ${PHP_SOURCE_DIR}/ext/phar)
include(${PHP_SOURCE_DIR}/ext/phar/cmake/GenerateGrammar.cmake)

set(CMAKE_CURRENT_SOURCE_DIR ${PHP_SOURCE_DIR}/ext/standard)
set(CMAKE_CURRENT_BINARY_DIR ${PHP_SOURCE_DIR}/ext/standard)
include(${PHP_SOURCE_DIR}/ext/standard/cmake/GenerateGrammar.cmake)

set(CMAKE_CURRENT_SOURCE_DIR ${PHP_SOURCE_DIR}/sapi/phpdbg)
set(CMAKE_CURRENT_BINARY_DIR ${PHP_SOURCE_DIR}/sapi/phpdbg)
include(${PHP_SOURCE_DIR}/sapi/phpdbg/cmake/GenerateGrammar.cmake)

set(CMAKE_CURRENT_SOURCE_DIR ${PHP_SOURCE_DIR}/Zend)
set(CMAKE_CURRENT_BINARY_DIR ${PHP_SOURCE_DIR}/Zend)
include(${PHP_SOURCE_DIR}/Zend/cmake/GenerateGrammar.cmake)
