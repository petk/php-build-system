<!-- This is auto-generated file. -->
# Findlibavif

* Module source code: [Findlibavif.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findlibavif.cmake)

Find the libavif library.

This is a helper in case system doesn't have the library's Config find module.

Module defines the following `IMPORTED` target(s):

* `libavif::libavif` - The package library, if found.

Result variables:

* `libavif_FOUND` - Whether the package has been found.
* `libavif_INCLUDE_DIRS` - Include directories needed to use this package.
* `libavif_LIBRARIES` - Libraries needed to link to the package library.
* `libavif_VERSION` - Package version, if found.

Cache variables:

* `libavif_INCLUDE_DIR` - Directory containing package library headers.
* `libavif_LIBRARY` - The path to the package library.

Hints:

The `libavif_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(libavif)
```

## Customizing search locations

To customize where to look for the libavif package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LIBAVIF_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/libavif;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DLIBAVIF_ROOT=/opt/libavif \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
