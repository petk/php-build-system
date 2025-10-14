<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindQDBM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindQDBM.cmake)

# FindQDBM

Finds the QDBM library:

```cmake
find_package(QDBM [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `QDBM::QDBM` - The package library, if found.

## Result variables

This module defines the following variables:

* `QDBM_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `QDBM_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `QDBM_INCLUDE_DIR` - Directory containing package library headers.
* `QDBM_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(QDBM)
target_link_libraries(example PRIVATE QDBM::QDBM)
```

## Customizing search locations

To customize where to look for the QDBM package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `QDBM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/QDBM;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DQDBM_ROOT=/opt/QDBM \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
