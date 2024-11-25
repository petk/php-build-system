#[=============================================================================[
# The pdo_mysql extension

Configure the `pdo_mysql` extension.

This extension provides PDO interface for using MySQL-compatible databases.

## EXT_PDO_MYSQL

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `pdo_mysql` extension.

## EXT_PDO_MYSQL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## EXT_PDO_MYSQL_DRIVER

* Default: `mysqlnd`
* Values: `mysqlnd|mysql`

Select the MySQL driver for the `pdo_mysql` extension.

The `mysql` driver uses system MySQL library. Where to find the MySQL library
installation on the system, can be customized with the `MYSQL_ROOT` and
`MySQL_CONFIG_EXECUTABLE` variables.
#]=============================================================================]

# TODO: Integrate zlib functionality.

project(
  PhpExtensionPdoMysql
  DESCRIPTION
    "MySQL-compatible database support in PDO (PHP Data Objects) interface"
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Set)

option(EXT_PDO_MYSQL "Enable the pdo_mysql extension")

add_feature_info(
  "ext/pdo_mysql"
  EXT_PDO_MYSQL
  "MySQL-compatible database support in PDO (PHP Data Objects)"
)

cmake_dependent_option(
  EXT_PDO_MYSQL_SHARED
  "Build the pdo_mysql extension as a shared library"
  OFF
  "EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

# Driver selection option.
php_set(
  EXT_PDO_MYSQL_DRIVER
  CHOICES "mysqlnd" "mysql"
  IF EXT_PDO_MYSQL
  DOC
    "Select MySQL driver: mysqlnd (MySQL Native Driver, recommended) or mysql "
    "(system MySQL)"
)
mark_as_advanced(EXT_PDO_MYSQL_DRIVER)

if(NOT EXT_PDO_MYSQL)
  return()
endif()

if(EXT_PDO_MYSQL_SHARED)
  add_library(php_pdo_mysql SHARED)
else()
  add_library(php_pdo_mysql)
endif()

target_sources(
  php_pdo_mysql
  PRIVATE
    mysql_driver.c
    mysql_statement.c
    pdo_mysql.c
)

add_dependencies(php_pdo_mysql php_pdo)

target_compile_definitions(
  php_pdo_mysql
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

target_include_directories(
  php_pdo_mysql
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

if(EXT_MYSQL_SOCKET)
  if(EXT_MYSQL_SOCKET_PATH)
    set(MySQL_Socket_PATH "${EXT_MYSQL_SOCKET_PATH}")
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

if(NOT EXT_PDO_MYSQL_DRIVER STREQUAL "mysql")
  add_dependencies(php_pdo_mysql php_mysqlnd)

  set(PDO_USE_MYSQLND TRUE)
else()
  find_package(MySQL COMPONENTS Lib OPTIONAL_COMPONENTS Socket)
  set_package_properties(MySQL PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_mysql extension."
  )

  target_link_libraries(php_pdo_mysql PRIVATE MySQL::MySQL)

  if(MySQL_Socket_PATH)
    set(PDO_MYSQL_UNIX_ADDR "${MySQL_Socket_PATH}")
  endif()
endif()

configure_file(config.cmake.h.in config.h)
