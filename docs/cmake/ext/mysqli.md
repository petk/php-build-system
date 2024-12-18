<!-- This is auto-generated file. -->
* Source code: [ext/mysqli/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/mysqli/CMakeLists.txt)

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
