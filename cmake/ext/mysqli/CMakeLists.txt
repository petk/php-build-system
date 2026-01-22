#[=============================================================================[
# The mysqli extension

The `mysqli` extension provides MySQL-compatible databases support.

## Configuration options

### PHP_EXT_MYSQLI

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_MYSQLI_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_MYSQLI_SOCKET

* Default: `OFF`
* Values: `ON|OFF`

Enables searching of MySQL Unix socket pointer from default locations and uses
it as a default value for the `mysqli.default_socket` PHP INI directive. If no
suitable MySQL socket pointer can be found on the host system, default socket
pointer value isn't defined.

> [!NOTE]
> This option is not available when the target system is Windows.

When connecting to a MySQL-compatible server in PHP, connection host can be
specified as a domain (for example, `localhost`, etc.), or an IP address (e.g.,
`127.0.0.1`). When using `localhost`, the socket path is also needed to be
specified, e.g., as `mysqli.default_socket` PHP INI directive. This option
determines the default value for the `mysqli.default_socket` INI directive.

```php
// connection-examples.php

// Uses Unix socket
$mysqli = new mysqli('localhost', 'user', 'password', 'db');

// Uses TCP/IP
$mysqli = new mysqli('127.0.0.1', 'user', 'password', 'db');

// Socket can be also explicitly specified
$mysqli = new mysqli('localhost', 'user', 'password', 'db', null, '/path/to/mysql.sock');
```

### PHP_EXT_MYSQLI_SOCKET_PATH

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
  PHP_EXT_MYSQLI
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

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

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(
    CACHE{PHP_EXT_MYSQLI_SOCKET}
    TYPE INTERNAL
    HELP "mysqli: Use MySQL Unix socket pointer from default location"
    VALUE FALSE
  )

  set(
    CACHE{PHP_EXT_MYSQLI_SOCKET_PATH}
    TYPE INTERNAL
    HELP
      "mysqli: Path to the MySQL Unix socket pointer. "
      "If unspecified, default locations are searched."
    VALUE ""
  )
else()
  option(
    PHP_EXT_MYSQLI_SOCKET
    "mysqli: Use MySQL Unix socket pointer from default location"
  )
  mark_as_advanced(PHP_EXT_MYSQLI_SOCKET)

  set(
    CACHE{PHP_EXT_MYSQLI_SOCKET_PATH}
    TYPE STRING
    HELP
      "mysqli: Path to the MySQL Unix socket pointer. "
      "If unspecified, default locations are searched."
    VALUE ""
  )
  mark_as_advanced(PHP_EXT_MYSQLI_SOCKET_PATH)
endif()

if(NOT PHP_EXT_MYSQLI)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(mysqli)

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

if(PHP_EXT_MYSQLI_SOCKET_PATH)
  set(MySQL_SOCKET_PATH "${PHP_EXT_MYSQLI_SOCKET_PATH}")
elseif(PHP_EXT_MYSQLI_SOCKET)
  find_package(MySQL OPTIONAL_COMPONENTS Server)
  set_package_properties(
    MySQL
    PROPERTIES
      PURPOSE "Necessary to set the MySQL socket in mysqli extension."
  )
else()
  set(MySQL_SOCKET_PATH "")
endif()

if(MySQL_SOCKET_PATH)
  set(PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_SOCKET_PATH}")
endif()

configure_file(cmake/config.h.in config.h)
