#[=============================================================================[
# The pdo extension

This extension provides support for PHP Data Objects (PDO).

## Configuration options

### PHP_EXT_PDO

* Default: `ON`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PDO
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_PDO "Enable the pdo extension" ON)

add_feature_info(
  "ext/pdo"
  PHP_EXT_PDO
  "PHP Data Objects (PDO)"
)

if(NOT PHP_EXT_PDO)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo)

if(PHP_EXT_PDO STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_pdo MODULE)
else()
  add_library(php_ext_pdo OBJECT)
endif()

target_sources(
  php_ext_pdo
  PRIVATE
    pdo_dbh.c
    pdo_dbh.stub.php
    pdo_sql_parser.c
    pdo_sqlstate.c
    pdo_stmt.c
    pdo_stmt.stub.php
    pdo.c
    pdo.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_pdo_driver.h
        php_pdo_error.h
        php_pdo.h
)

target_include_directories(php_ext_pdo PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

set_property(
  TARGET php_ext_pdo
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS spl
)

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)
