<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindMySQL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMySQL.cmake)

# FindMySQL

Finds MySQL-compatible (MySQL, MariaDB, Percona, etc.) database:

```cmake
find_package(MySQL)
```

This is customized find module for PHP mysqli and pdo_mysql extensions. It
searches for MySQL Unix socket pointer and can be extended more in the future.

## Components

* `Socket` - The MySQL Unix socket pointer.
* `Lib` - The MySQL library or client.

## Imported targets

This module provides the following imported targets:

* `MySQL::MySQL` - The MySQL-compatible library, if found, when using the Lib
  component.

## Result variables

* `MySQL_FOUND` - Boolean indicating whether the package with requested
  components was found.
* `MySQL_Socket_FOUND` - Boolean indicating whether the MySQL Unix socket
  pointer has been determined.
* `MySQL_Socket_PATH` - Path to the MySQL Unix socket if one has been found in
  the predefined default locations.
* `MySQL_Lib_FOUND` - Whether the Lib component was found.

## Cache variables

* `MySQL_CONFIG_EXECUTABLE` - The mysql_config command-line tool for getting
  MySQL installation info.
* `Mysql_INCLUDE_DIR` - Directory containing package library headers.
* `Mysql_LIBRARY` - The path to the package library.

Hints:

* The `MySQL_Socket_PATH` variable can be overridden.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(MySQL)
```

## Customizing search locations

To customize where to look for the MySQL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `MYSQL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/MySQL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DMYSQL_ROOT=/opt/MySQL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
