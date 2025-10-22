#[=============================================================================[
# The mysqli extension

Configure the `mysqli` extension.

This extension provides MySQL-compatible databases support.

## PHP_EXT_MYSQLI

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_MYSQLI_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_MYSQL_SOCKET

* Default: `OFF`
* Values: `ON|OFF`

mysqli/pdo_mysql: Use MySQL Unix socket pointer from default locations.

> [!NOTE]
> This option is not available when the target system is Windows.

## PHP_EXT_MYSQL_SOCKET_PATH

* Default: empty

mysqli/pdo_mysql: Path to the MySQL Unix socket pointer location. If
unspecified, default locations are searched.

> [!NOTE]
> This option is not available when the target system is Windows.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_MYSQLI
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Set)

option(PHP_EXT_MYSQLI "Enable the mysqli extension")

add_feature_info(
  "ext/mysqli"
  PHP_EXT_MYSQLI
  "MySQL-compatible databases support"
)

cmake_dependent_option(
  PHP_EXT_MYSQLI_SHARED
  "Build the mysqli extension as a shared library"
  OFF
  PHP_EXT_MYSQLI
  OFF
)

# Common configuration option for mysqli and pdo_mysql extensions.
cmake_dependent_option(
  PHP_EXT_MYSQL_SOCKET
  "mysqli/pdo_mysql: Use MySQL Unix socket pointer from default locations"
  OFF
  [[(PHP_EXT_MYSQLI OR PHP_EXT_PDO_MYSQL) AND NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(PHP_EXT_MYSQL_SOCKET)

php_set(
  PHP_EXT_MYSQL_SOCKET_PATH
  TYPE FILEPATH
  IF [[(PHP_EXT_MYSQLI OR PHP_EXT_PDO_MYSQL) AND PHP_EXT_MYSQL_SOCKET]]
  VALUE ""
  DOC
    "mysqli/pdo_mysql: Specify path to the MySQL Unix socket pointer location. "
    "If unspecified, default locations are searched."
)
mark_as_advanced(PHP_EXT_MYSQL_SOCKET_PATH)

if(NOT PHP_EXT_MYSQLI)
  return()
endif()

if(PHP_EXT_MYSQLI_SHARED)
  add_library(php_ext_mysqli MODULE)
else()
  add_library(php_ext_mysqli OBJECT)
endif()

target_sources(
  php_ext_mysqli
  PRIVATE
    mysqli_api.c
    mysqli_driver.c
    mysqli_exception.c
    mysqli_nonapi.c
    mysqli_prop.c
    mysqli_report.c
    mysqli_result_iterator.c
    mysqli_warning.c
    mysqli.c
    mysqli.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        mysqli_mysqlnd.h
        php_mysqli_structs.h
)

add_dependencies(php_ext_mysqli php_ext_mysqlnd php_ext_spl)

target_compile_definitions(php_ext_mysqli PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(PHP_EXT_MYSQL_SOCKET)
  if(PHP_EXT_MYSQL_SOCKET_PATH)
    set(MySQL_Socket_PATH "${PHP_EXT_MYSQL_SOCKET_PATH}")
  endif()

  find_package(MySQL OPTIONAL_COMPONENTS Socket)
  set_package_properties(
    MySQL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to set the MySQL socket in mysqli extension."
  )
endif()

if(MySQL_Socket_PATH)
  set(PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_Socket_PATH}")
endif()

configure_file(cmake/config.h.in config.h)
