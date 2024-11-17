<!-- This is auto-generated file. -->
# FindGD

* Module source code: [FindGD.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGD.cmake)

Find the GD library.

Module defines the following `IMPORTED` target(s):

* `GD::GD` - The package library, if found.

## Result variables

* `GD_FOUND` - Whether the package has been found.
* `GD_INCLUDE_DIRS` - Include directories needed to use this package.
* `GD_LIBRARIES` - Libraries needed to link to the package library.
* `GD_VERSION` - Package version, if found.

## Cache variables

* `GD_INCLUDE_DIR` - Directory containing package library headers.
* `GD_LIBRARY` - The path to the package library.

## Basic usage

```cmake
# CMakeLists.txt
find_package(GD)
```

## Customizing search locations

To customize where to look for the GD package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `GD_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/GD;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DGD_ROOT=/opt/GD \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
