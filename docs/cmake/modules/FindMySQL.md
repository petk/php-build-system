# FindMySQL

See: [FindMySQL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMySQL.cmake)

## Basic usage

```cmake
include(cmake/FindMySQL.cmake)
```

Find MySQL-compatible (MySQL, MariaDB, Percona, etc.) database.

This is customized find module for PHP mysqli and pdo_mysql extensions. It
searches for MySQL Unix socket pointer and can be extended more in the future.

Components:

* `Socket` - The MySQL Unix socket pointer.
* `Lib` - The MySQL library or client.

Module defines the following `IMPORTED` target(s):

* `MySQL::MySQL` - The MySQL-compatible library, if found, when using the Lib
  component.

Result variables:

* `MySQL_Socket_FOUND` - Whether the MySQL Unix socket pointer has been
  determined.
* `MySQL_Socket_PATH` - Path to the MySQL Unix socket if one has been found in
  the predefined default locations.
* `MySQL_Lib_FOUND` - Whether the Lib component has been found.
* `MySQL_FOUND` - Whether the package with requested components has been found.
* `MySQL_INCLUDE_DIRS` - MySQL include directories.
* `MySQL_LIBRARIES` - MySQL libraries.

Cache variables:

* `MySQL_CONFIG_EXECUTABLE` - The mysql_config command-line tool for getting
  MySQL installation info.
* `Mysql_INCLUDE_DIR` - Directory containing package library headers.
* `Mysql_LIBRARY` - The path to the package library.

Hints:

* The `MySQL_Socket_PATH` variable can be overridden.
* The `MySQL_ROOT` variable adds custom search path.
