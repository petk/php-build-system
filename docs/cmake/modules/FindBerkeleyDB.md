<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindBerkeleyDB.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindBerkeleyDB.cmake)

# FindBerkeleyDB

Find the Berkeley DB library.

Module defines the following `IMPORTED` target(s):

* `BerkeleyDB::BerkeleyDB` - The package library, if found.

## Result variables

* `BerkeleyDB_FOUND` - Whether the package has been found.
* `BerkeleyDB_INCLUDE_DIRS` - Include directories needed to use this package.
* `BerkeleyDB_LIBRARIES` - Libraries needed to link to the package library.
* `BerkeleyDB_VERSION` - Package version, if found.

## Cache variables

* `BerkeleyDB_INCLUDE_DIR` - Directory containing package library headers.
* `BerkeleyDB_LIBRARY` - The path to the package library.
* `BerkeleyDB_DB1_INCLUDE_DIR` - Directory containing headers for DB1 emulation
  support in Berkeley DB.

## Hints

* Set `BerkeleyDB_USE_DB1` to `TRUE` before calling `find_package(BerkeleyDB)`
  to enable the Berkeley DB 1.x support/emulation.

## Basic usage

```cmake
# CMakeLists.txt
find_package(BerkeleyDB)
```

## Customizing search locations

To customize where to look for the BerkeleyDB package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `BERKELEYDB_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/BerkeleyDB;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DBERKELEYDB_ROOT=/opt/BerkeleyDB \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
