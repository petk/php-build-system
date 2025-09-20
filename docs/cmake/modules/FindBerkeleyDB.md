<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindBerkeleyDB.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindBerkeleyDB.cmake)

# FindBerkeleyDB

Finds the Berkeley DB library:

```cmake
find_package(BerkeleyDB [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `BerkeleyDB::BerkeleyDB` - The package library, if found.

## Result variables

* `BerkeleyDB_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `BerkeleyDB_VERSION` - The version of package found.

## Cache variables

* `BerkeleyDB_INCLUDE_DIR` - Directory containing package library headers.
* `BerkeleyDB_LIBRARY` - The path to the package library.
* `BerkeleyDB_DB1_INCLUDE_DIR` - Directory containing headers for DB1 emulation
  support in Berkeley DB.

## Hints

* Set `BerkeleyDB_USE_DB1` to `TRUE` before calling `find_package(BerkeleyDB)`
  to enable the Berkeley DB 1.x support/emulation.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(BerkeleyDB)
target_link_libraries(example PRIVATE BerkeleyDB::BerkeleyDB)
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
