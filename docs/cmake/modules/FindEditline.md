<!-- This is auto-generated file. -->
# FindEditline

* Module source code: [FindEditline.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindEditline.cmake)

Find the Editline library.

Module defines the following `IMPORTED` target(s):

* `Editline::Editline` - The Editline library, if found.

Result variables:

* `Editline_FOUND` - Whether the package has been found.
* `Editline_INCLUDE_DIRS` - Include directories needed to use this package.
* `Editline_LIBRARIES` - Libraries needed to link to the package library.
* `Editline_VERSION` - Package version, if found.

Cache variables:

* `Editline_INCLUDE_DIR` - Directory containing package library headers.
* `Editline_LIBRARY` - The path to the package library.

Hints:

The `Editline_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(Editline)
```

## Customizing search locations

To customize where to look for the Editline package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `EDITLINE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/Editline;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DEDITLINE_ROOT=/opt/Editline \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
