<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindSQLite3.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSQLite3.cmake)

# FindSQLite3

This module overrides the upstream CMake `FindSQLite3` module with few
customizations:

* Added imported target `SQLite3::SQLite3` available as of CMake 4.3.

See: https://cmake.org/cmake/help/latest/module/FindSQLite3.html

## Customizing search locations

To customize where to look for the SQLite3 package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SQLITE3_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/SQLite3;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DSQLITE3_ROOT=/opt/SQLite3 \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
