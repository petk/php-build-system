<!-- This is auto-generated file. -->
# FindMM

* Module source code: [FindMM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMM.cmake)

Find the mm library.

Module defines the following `IMPORTED` target(s):

* `MM::MM` - The package library, if found.

Result variables:

* `MM_FOUND` - Whether the package has been found.
* `MM_INCLUDE_DIRS` - Include directories needed to use this package.
* `MM_LIBRARIES` - Libraries needed to link to the package library.

Cache variables:

* `MM_INCLUDE_DIR` - Directory containing package library headers.
* `MM_LIBRARY` - The path to the package library.

Hints:

The `MM_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(MM)
```

## Customizing search locations

To customize where to look for the MM package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `MM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/MM;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DMM_ROOT=/opt/MM \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
