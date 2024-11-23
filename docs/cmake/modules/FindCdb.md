<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCdb.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCdb.cmake)

# FindCdb

Find the cdb library.

Module defines the following `IMPORTED` target(s):

* `Cdb::Cdb` - The package library, if found.

## Result variables

* `Cdb_FOUND` - Whether the package has been found.
* `Cdb_INCLUDE_DIRS` - Include directories needed to use this package.
* `Cdb_LIBRARIES` - Libraries needed to link to the package library.
* `Cdb_VERSION` - Package version, if found.

## Cache variables

* `Cdb_INCLUDE_DIR` - Directory containing package library headers.
* `Cdb_LIBRARY` - The path to the package library.

## Basic usage

```cmake
# CMakeLists.txt
find_package(Cdb)
```

## Customizing search locations

To customize where to look for the Cdb package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CDB_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Cdb;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCDB_ROOT=/opt/Cdb \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
