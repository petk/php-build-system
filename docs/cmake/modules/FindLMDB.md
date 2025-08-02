<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindLMDB.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindLMDB.cmake)

# FindLMDB

Finds the LMDB library:

```cmake
find_package(LMDB [<version>] [...])
```

## Imported targets

This module defines the following imported targets:

* `LMDB::LMDB` - The package library, if found.

## Result variables

* `LMDB_FOUND` - Boolean indicating whether the package is found.
* `LMDB_VERSION` - The version of package found.

## Cache variables

* `LMDB_INCLUDE_DIR` - Directory containing package library headers.
* `LMDB_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(LMDB)
target_link_libraries(example PRIVATE LMDB::LMDB)
```

## Customizing search locations

To customize where to look for the LMDB package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LMDB_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/LMDB;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DLMDB_ROOT=/opt/LMDB \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
