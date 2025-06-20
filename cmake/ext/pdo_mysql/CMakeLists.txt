#[=============================================================================[
# The pdo_mysql extension

Configure the `pdo_mysql` extension.

This extension provides PDO interface for using MySQL-compatible databases.

## PHP_EXT_PDO_MYSQL

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `pdo_mysql` extension.

## PHP_EXT_PDO_MYSQL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_PDO_MYSQL_DRIVER

* Default: `mysqlnd`
* Values: `mysqlnd|mysql`

Select the MySQL driver for the `pdo_mysql` extension.

The `mysql` driver uses system MySQL library. Where to find the MySQL library
installation on the system, can be customized with the `MYSQL_ROOT` and
`MySQL_CONFIG_EXECUTABLE` variables.
#]=============================================================================]

# TODO: Integrate zlib functionality.

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionPdoMysql
  DESCRIPTION
    "MySQL-compatible databases support in PDO (PHP Data Objects) interface"
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Set)

option(PHP_EXT_PDO_MYSQL "Enable the pdo_mysql extension")

add_feature_info(
  "ext/pdo_mysql"
  PHP_EXT_PDO_MYSQL
  "MySQL-compatible databases PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_MYSQL_SHARED
  "Build the pdo_mysql extension as a shared library"
  OFF
  "PHP_EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

# Driver selection option.
php_set(
  PHP_EXT_PDO_MYSQL_DRIVER
  CHOICES "mysqlnd" "mysql"
  IF PHP_EXT_PDO_MYSQL
  DOC
    "Select MySQL driver: mysqlnd (MySQL Native Driver, recommended) or mysql "
    "(system MySQL)"
)
mark_as_advanced(PHP_EXT_PDO_MYSQL_DRIVER)

if(NOT PHP_EXT_PDO_MYSQL)
  return()
endif()

if(PHP_EXT_PDO_MYSQL_SHARED)
  add_library(php_ext_pdo_mysql SHARED)
else()
  add_library(php_ext_pdo_mysql)
endif()

target_sources(
  php_ext_pdo_mysql
  PRIVATE
    mysql_driver.c
    mysql_sql_parser.c
    mysql_statement.c
    pdo_mysql.c
    pdo_mysql.stub.php
)

add_dependencies(php_ext_pdo_mysql php_ext_pdo)

target_compile_definitions(
  php_ext_pdo_mysql
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

if(PHP_EXT_MYSQL_SOCKET)
  if(PHP_EXT_MYSQL_SOCKET_PATH)
    set(MySQL_Socket_PATH "${PHP_EXT_MYSQL_SOCKET_PATH}")
  endif()

  find_package(MySQL OPTIONAL_COMPONENTS Socket)
  set_package_properties(
    MySQL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to set the MySQL socket in pdo_mysql extension."
  )
endif()

if(MySQL_Socket_PATH)
  set(PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_Socket_PATH}")
endif()

if(NOT PHP_EXT_PDO_MYSQL_DRIVER STREQUAL "mysql")
  add_dependencies(php_ext_pdo_mysql php_ext_mysqlnd)

  set(PDO_USE_MYSQLND TRUE)

  add_feature_info("ext/pdo_mysql mysqlnd" TRUE "MySQL native driver")
else()
  find_package(MySQL COMPONENTS Lib OPTIONAL_COMPONENTS Socket)
  set_package_properties(MySQL PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_mysql extension."
  )

  target_link_libraries(php_ext_pdo_mysql PRIVATE MySQL::MySQL)

  if(MySQL_Socket_PATH)
    set(PDO_MYSQL_UNIX_ADDR "${MySQL_Socket_PATH}")
  endif()

  add_feature_info("ext/pdo_mysql mysql" TRUE "system MySQL library driver")
endif()

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

configure_file(cmake/config.h.in config.h)
