<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindPostgreSQL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPostgreSQL.cmake)

# FindPostgreSQL

This module overrides the upstream CMake `FindPostgreSQL` module with few
customizations:

* Added PostgreSQL_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindPostgreSQL.html

## Customizing search locations

To customize where to look for the PostgreSQL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `POSTGRESQL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/PostgreSQL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DPOSTGRESQL_ROOT=/opt/PostgreSQL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
