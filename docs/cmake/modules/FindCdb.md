<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCdb.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCdb.cmake)

# FindCdb

Finds the cdb library:

```cmake
find_package(Cdb [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Cdb::Cdb` - The package library, if found.

## Result variables

This module defines the following variables:

* `Cdb_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `Cdb_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Cdb_INCLUDE_DIR` - Directory containing package library headers.
* `Cdb_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Cdb)
target_link_libraries(example PRIVATE Cdb::Cdb)
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
