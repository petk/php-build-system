<!-- This is auto-generated file. -->
* Source code: [ext/pdo_mysql/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/pdo_mysql/CMakeLists.txt)

# The pdo_mysql extension

The `pdo_mysql` extension provides PDO interface for using MySQL-compatible
databases.

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
