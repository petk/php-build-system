<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindIntl.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindIntl.cmake)

# FindIntl

Find the Intl library.

Module overrides the upstream CMake `FindIntl` module with few customizations.

Enables finding Intl library with `INTL_ROOT` hint variable.

See: https://cmake.org/cmake/help/latest/module/FindIntl.html

## Usage

```cmake
# CMakeLists.txt
find_package(Intl)
```

## Customizing search locations

To customize where to look for the Intl package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `INTL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Intl;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DINTL_ROOT=/opt/Intl \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
