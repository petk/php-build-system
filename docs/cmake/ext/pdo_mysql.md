<!-- This is auto-generated file. -->
* Source code: [ext/pdo_mysql/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/pdo_mysql/CMakeLists.txt)

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
