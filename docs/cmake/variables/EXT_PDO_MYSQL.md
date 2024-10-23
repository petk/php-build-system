# `EXT_PDO_MYSQL`

Default: `OFF`

Values: `ON|OFF`

Enable the PHP `pdo_mysql` extension.

**Additional variables:**

## `EXT_PDO_MYSQL_SHARED`

Default: `OFF`

Values: `ON|OFF`

Build extension as shared library.

## `EXT_PDO_MYSQL_DRIVER`

Default: `mysqlnd`

Values: `mysqlnd|mysql`

Select the MySQL driver for the `pdo_mysql` extension.

The `mysql` driver uses system MySQL library. Where to find the MySQL library
installation on the system, can be customized with the `MySQL_ROOT` and
`MySQL_CONFIG_EXECUTABLE` variables.
