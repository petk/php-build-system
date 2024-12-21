#!/usr/bin/env -S cmake -P
#
# Command-line script to generate the lexer and parser files using re2c and
# bison.
#
# Run as: `cmake -P cmake/scripts/GenerateLexersParsers.cmake`
#
# re2c and bison options must be manually synced with those used in the
# CMakeLists.txt files.
#
# TODO 1: Should the Bison-generated report files (*.output) really be also
# created by this script (the `VERBOSE REPORT_FILE <file>` options)? PHP still
# packages these reports also in the archive release files?!
#
# TODO 2: Add patching for Zend/zend_language_parser.{h,c} files
#
# TODO 3: Use Configuration.cmake for versions and default flags.
#
# TODO 4: Add remaining missing features to FindBISON.cmake module.

cmake_minimum_required(VERSION 3.25...3.31)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

set(PHP_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../../)

if(NOT EXISTS ${PHP_SOURCE_DIR}/main/php_version.h)
  message(FATAL_ERROR "This script should be run inside the php-src repository")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../modules)

include(${CMAKE_CURRENT_LIST_DIR}/../Configuration.cmake)

set(
  RE2C_DEFAULT_OPTIONS
    --no-generation-date # Suppress date output in the generated file.
    -i # Do not output line directives.
)

set(RE2C_DISABLE_DOWNLOAD TRUE)

find_package(BISON 3.0.0 REQUIRED)
find_package(RE2C 1.0.3 REQUIRED)

# ext/json
bison_generate(
  php_ext_json_parser
  ${PHP_SOURCE_DIR}/ext/json/json_parser.y
  ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.c
  COMPILE_OPTIONS -Wall -l
  VERBOSE REPORT_FILE ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.output
  DEFINES_FILE ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.h
)
re2c_target(
  php_ext_json_scanner
  ${PHP_SOURCE_DIR}/ext/json/json_scanner.re
  ${PHP_SOURCE_DIR}/ext/json/json_scanner.c
  HEADER ${PHP_SOURCE_DIR}/ext/json/php_json_scanner_defs.h
  OPTIONS -bc
)

# ext/pdo
re2c_target(
  php_ext_pdo_sql_parser
  ${PHP_SOURCE_DIR}/ext/pdo/pdo_sql_parser.re
  ${PHP_SOURCE_DIR}/ext/pdo/pdo_sql_parser.c
)

# ext/phar
re2c_target(
  php_ext_phar_path_check
  ${PHP_SOURCE_DIR}/ext/phar/phar_path_check.re
  ${PHP_SOURCE_DIR}/ext/phar/phar_path_check.c
  OPTIONS -b
)

# ext/standard
re2c_target(
  php_ext_standard_var_unserializer
  ${PHP_SOURCE_DIR}/ext/standard/var_unserializer.re
  ${PHP_SOURCE_DIR}/ext/standard/var_unserializer.c
  OPTIONS -b
)
re2c_target(
  php_ext_standard_url_scanner_ex
  ${PHP_SOURCE_DIR}/ext/standard/url_scanner_ex.re
  ${PHP_SOURCE_DIR}/ext/standard/url_scanner_ex.c
  OPTIONS -b
)

# sapi/phpdbg
bison_generate(
  php_sapi_phpdbg_parser
  ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.y
  ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.c
  COMPILE_OPTIONS -Wall -l
  VERBOSE REPORT_FILE ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.output
  DEFINES_FILE ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.h
)
re2c_target(
  php_sapi_phpdbg_lexer
  ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_lexer.l
  ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_lexer.c
  OPTIONS -cbdF
)

# Zend
bison_generate(
  zend_ini_parser
  ${PHP_SOURCE_DIR}/Zend/zend_ini_parser.y
  ${PHP_SOURCE_DIR}/Zend/zend_ini_parser.c
  COMPILE_OPTIONS -Wall -l
  VERBOSE REPORT_FILE ${PHP_SOURCE_DIR}/Zend/zend_ini_parser.output
  DEFINES_FILE ${PHP_SOURCE_DIR}/Zend/zend_ini_parser.h
)
# TODO: Also patch the file here:
bison_generate(
  zend_language_parser
  ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
  ${PHP_SOURCE_DIR}/Zend/zend_language_parser.c
  COMPILE_OPTIONS -Wall -l
  VERBOSE REPORT_FILE ${PHP_SOURCE_DIR}/Zend/zend_language_parser.output
  DEFINES_FILE ${PHP_SOURCE_DIR}/Zend/zend_language_parser.h
)
re2c_target(
  zend_language_scanner
  ${PHP_SOURCE_DIR}/Zend/zend_language_scanner.l
  ${PHP_SOURCE_DIR}/Zend/zend_language_scanner.c
  HEADER ${PHP_SOURCE_DIR}/Zend/zend_language_scanner_defs.h
  OPTIONS --case-inverted -cbdF
)
re2c_target(
  zend_ini_scanner
  ${PHP_SOURCE_DIR}/Zend/zend_ini_scanner.l
  ${PHP_SOURCE_DIR}/Zend/zend_ini_scanner.c
  HEADER ${PHP_SOURCE_DIR}/Zend/zend_ini_scanner_defs.h
  OPTIONS --case-inverted -cbdF
)
