<!-- This is auto-generated file. -->
* Source code: [ext/mysqli/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/mysqli/CMakeLists.txt)

# The mysqli extension

This extension provides MySQL-compatible databases support.

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
