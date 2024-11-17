<!-- This is auto-generated file. -->
# FindQDBM

* Module source code: [FindQDBM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindQDBM.cmake)

Find the QDBM library.

Module defines the following `IMPORTED` target(s):

* `QDBM::QDBM` - The package library, if found.

## Result variables

* `QDBM_FOUND` - Whether the package has been found.
* `QDBM_INCLUDE_DIRS` - Include directories needed to use this package.
* `QDBM_LIBRARIES` - Libraries needed to link to the package library.
* `QDBM_VERSION` - Package version, if found.

## Cache variables

* `QDBM_INCLUDE_DIR` - Directory containing package library headers.
* `QDBM_LIBRARY` - The path to the package library.

## Hints

* The `QDBM_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(QDBM)
```

## Customizing search locations

To customize where to look for the QDBM package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `QDBM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/QDBM;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DQDBM_ROOT=/opt/QDBM \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
