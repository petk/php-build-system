<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindGMP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGMP.cmake)

# FindGMP

Find the GMP library.

Module defines the following `IMPORTED` target(s):

* `GMP::GMP` - The package library, if found.

## Result variables

* `GMP_FOUND` - Whether the package has been found.
* `GMP_INCLUDE_DIRS` - Include directories needed to use this package.
* `GMP_LIBRARIES` - Libraries needed to link to the package library.
* `GMP_VERSION` - Package version, if found.

## Cache variables

* `GMP_INCLUDE_DIR` - Directory containing package library headers.
* `GMP_LIBRARY` - The path to the package library.

## Basic usage

```cmake
# CMakeLists.txt
find_package(GMP)
```

## Customizing search locations

To customize where to look for the GMP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `GMP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/GMP;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DGMP_ROOT=/opt/GMP \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
