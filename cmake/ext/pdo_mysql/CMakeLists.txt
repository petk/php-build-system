#[=============================================================================[
# The pdo_mysql extension

This extension provides PDO interface for using MySQL-compatible databases.

## Configuration options

### PHP_EXT_PDO_MYSQL

* Default: `OFF`
* Values: `ON|OFF`

Enables the PHP `pdo_mysql` extension.

### PHP_EXT_PDO_MYSQL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared library.

### PHP_EXT_PDO_MYSQL_DRIVER

* Default: `mysqlnd`
* Values: `mysqlnd|mysql`

Selects the MySQL driver for the `pdo_mysql` extension.

The `mysql` driver uses system MySQL client library (libmysqlclient). Where to
find the MySQL library installation on the system, can be customized with the
`MySQL_ROOT` and `MySQL_CONFIG_EXECUTABLE` variables.

### PHP_EXT_PDO_MYSQL_SOCKET

Enables searching of MySQL Unix socket pointer from default locations and uses
it as a default value for the `pdo_mysql.default_socket` PHP INI directive. If
no suitable MySQL socket pointer can be found on the host system, default socket
pointer value isn't defined.

> [!NOTE]
> This option is not available when the target system is Windows.

When connecting to a MySQL-compatible server in PHP, connection host can be
specified as a domain (for example, `localhost`, etc.), or an IP address (e.g.,
`127.0.0.1`). When using `localhost`, the socket path is also needed to be
specified, e.g., as `pdo_mysql.default_socket` PHP INI directive. This option
determines the default value for the `pdo_mysql.default_socket` INI directive.

```php
// connection-examples.php

// Uses Unix socket defined by the `pdo_mysql.default_socket` INI directive
$pdo = new PDO('mysql:host=localhost;dbname=db', 'user', 'password');

// Uses TCP/IP
$pdo = new PDO('mysql:host=127.0.0.1;dbname=db', 'user', 'password');

// Socket can be also explicitly specified
$pdo = new PDO('mysql:unix_socket=/path/to/mysql.sock;dbname=db', 'user', 'password');
```

### PHP_EXT_PDO_MYSQL_SOCKET_PATH

* Default: empty

The path to the MySQL Unix socket pointer location. If unspecified, default
locations are searched. This option is intended to override the default value
determined by the build system. For example, when building on some host system
and targeting some other with different MySQL socket pointer location.

> [!NOTE]
> This option is not available when the target system is Windows.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_PDO_MYSQL
  DESCRIPTION
    "MySQL-compatible databases support in PDO (PHP Data Objects) interface"
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

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
  PHP_EXT_PDO_MYSQL
  OFF
)

# Driver selection option.
set(
  CACHE{PHP_EXT_PDO_MYSQL_DRIVER}
  TYPE STRING
  HELP
    "Select MySQL driver: mysqlnd (MySQL Native Driver, recommended) or mysql "
    "(MySQL client library - libmysqlclient)"
  VALUE "mysqlnd"
)
set_property(CACHE PHP_EXT_PDO_MYSQL_DRIVER PROPERTY STRINGS "mysqlnd" "mysql")
mark_as_advanced(PHP_EXT_PDO_MYSQL_DRIVER)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(
    CACHE{PHP_EXT_PDO_MYSQL_SOCKET}
    TYPE INTERNAL
    HELP "pdo_mysql: Use MySQL Unix socket pointer from default location"
    VALUE FALSE
  )

  set(
    CACHE{PHP_EXT_PDO_MYSQL_SOCKET_PATH}
    TYPE INTERNAL
    HELP
      "pdo_mysql: Path to the MySQL Unix socket pointer. "
      "If unspecified, default locations are searched."
    VALUE ""
  )
else()
  option(
    PHP_EXT_PDO_MYSQL_SOCKET
    "pdo_mysql: Use MySQL Unix socket pointer from default location"
  )
  mark_as_advanced(PHP_EXT_PDO_MYSQL_SOCKET)

  set(
    CACHE{PHP_EXT_PDO_MYSQL_SOCKET_PATH}
    TYPE STRING
    HELP
      "pdo_mysql: Path to the MySQL Unix socket pointer. "
      "If unspecified, default locations are searched."
    VALUE ""
  )
  mark_as_advanced(PHP_EXT_PDO_MYSQL_SOCKET_PATH)
endif()

if(NOT PHP_EXT_PDO_MYSQL)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo_mysql)

if(PHP_EXT_PDO_MYSQL_SHARED)
  add_library(php_ext_pdo_mysql MODULE)
else()
  add_library(php_ext_pdo_mysql OBJECT)
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

if(PHP_EXT_PDO_MYSQL_SOCKET_PATH)
  set(MySQL_SOCKET_PATH "${PHP_EXT_PDO_MYSQL_SOCKET_PATH}")
elseif(PHP_EXT_PDO_MYSQL_SOCKET)
  find_package(MySQL OPTIONAL_COMPONENTS Server)
  set_package_properties(
    MySQL
    PROPERTIES
      PURPOSE "Necessary to set the MySQL socket in pdo_mysql extension."
  )
else()
  set(MySQL_SOCKET_PATH "")
endif()

if(MySQL_SOCKET_PATH)
  set(PDO_MYSQL_UNIX_ADDR "${MySQL_SOCKET_PATH}")
endif()

if(NOT PHP_EXT_PDO_MYSQL_DRIVER STREQUAL "mysql")
  add_dependencies(php_ext_pdo_mysql php_ext_mysqlnd)

  set(PDO_USE_MYSQLND TRUE)

  add_feature_info("ext/pdo_mysql mysqlnd" TRUE "MySQL native driver")
else()
  find_package(MySQL COMPONENTS Client)
  set_package_properties(
    MySQL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE
        "Necessary to enable the pdo_mysql extension with MySQL client library."
  )

  target_link_libraries(php_ext_pdo_mysql PRIVATE MySQL::MySQL)

  add_feature_info(
    "ext/pdo_mysql mysql"
    TRUE
    "MySQL client library driver - libmysqlclient"
  )
endif()

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

configure_file(cmake/config.h.in config.h)
