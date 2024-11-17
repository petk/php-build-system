<!-- This is auto-generated file. -->
# FindWebP

* Module source code: [FindWebP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindWebP.cmake)

Find the libwebp library.

Module defines the following `IMPORTED` target(s):

* `WebP::WebP` - The package library, if found.

## Result variables

* `WebP_FOUND` - Whether the package has been found.
* `WebP_INCLUDE_DIRS` - Include directories needed to use this package.
* `WebP_LIBRARIES` - Libraries needed to link to the package library.
* `WebP_VERSION` - Package version, if found.

## Cache variables

* `WebP_INCLUDE_DIR` - Directory containing package library headers.
* `WebP_LIBRARY` - The path to the package library.

## Basic usage

```cmake
# CMakeLists.txt
find_package(WebP)
```

## Customizing search locations

To customize where to look for the WebP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `WEBP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/WebP;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DWEBP_ROOT=/opt/WebP \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
