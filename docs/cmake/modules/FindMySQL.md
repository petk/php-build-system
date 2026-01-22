<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindMySQL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMySQL.cmake)

# FindMySQL

Finds MySQL-compatible (MySQL, MariaDB, Percona, etc.) database server (MySQL
Unix socket pointer) and MySQL client library:

```cmake
find_package(MySQL [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components, which can be specified with:

```cmake
find_package(
  MySQL
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
)
```

Supported components are:

* `Client` - The MySQL client library (libmysqlclient).
* `Server` - The MySQL-compatible database server (provides the Unix socket
  pointer).

If no components are specified, the module searches for the `Server` component
by default.

## Imported targets

This module provides the following imported targets:

* `MySQL::MySQL` - The interface target encapsulating the MySQL-compatible
  client library. This target is available only when the `Client` component was
  found.

## Result variables

This module defines the following variables:

* `MySQL_FOUND` - Boolean indicating whether the (requested version of) package
  with requested components was found.
* `MySQL_VERSION` -  The version of package found.
* `MySQL_Server_FOUND` - Boolean indicating whether the MySQL Unix socket
  pointer has been found.
* `MySQL_SOCKET_PATH` - Path to the MySQL Unix socket as defined by the
  `mysql_config --socket`, or if one was found in the predefined default
  locations. This variable is defined when the `Server` component is specified.
* `MySQL_Client_FOUND` - Boolean indicating whether the `Client` component was
  found.

## Cache variables

The following cache variables may also be set:

* `MySQL_CONFIG_EXECUTABLE` - The `mysql_config` command-line tool for getting
  MySQL installation info.
* `MySQL_INCLUDE_DIR` - Directory containing package library headers.
* `MySQL_LIBRARY` - The path to the MySQL client library.

## Hints

This module accepts the following variables before calling
`find_package(MySQL)`:

* `MySQL_SOCKET_PATH` - This variable can be also overridden from outside the
  module.

## Examples

In the following example, this module is used to find the MySQL client library
and then the imported target is linked to the project target:

```cmake
# CMakeLists.txt

find_package(MySQL COMPONENTS Client)

target_link_libraries(php_foo PRIVATE MySQL::MySQL)
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
