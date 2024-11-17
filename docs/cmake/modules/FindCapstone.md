<!-- This is auto-generated file. -->
# FindCapstone

* Module source code: [FindCapstone.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCapstone.cmake)

Find the Capstone library.

Module defines the following `IMPORTED` target(s):

* `Capstone::Capstone` - The package library, if found.

## Result variables

* `Capstone_FOUND` - Whether the package has been found.
* `Capstone_INCLUDE_DIRS` - Include directories needed to use this package.
* `Capstone_LIBRARIES` - Libraries needed to link to the package library.
* `Capstone_VERSION` - Package version, if found.

## Cache variables

* `Capstone_INCLUDE_DIR` - Directory containing package library headers.
* `Capstone_LIBRARY` - The path to the package library.

## Basic usage

```cmake
# CMakeLists.txt
find_package(Capstone)
```

## Customizing search locations

To customize where to look for the Capstone package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CAPSTONE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/Capstone;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DCAPSTONE_ROOT=/opt/Capstone \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
