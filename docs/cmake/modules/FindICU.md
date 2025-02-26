<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindICU.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindICU.cmake)

# FindICU

Find the ICU library.

See: https://cmake.org/cmake/help/latest/module/FindICU.html

This module overrides the upstream CMake `FindICU` module with few
customizations:

* Added pkg-config.

## Usage

```cmake
# CMakeLists.txt
find_package(ICU)
```

## Customizing search locations

To customize where to look for the ICU package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ICU_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/ICU;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DICU_ROOT=/opt/ICU \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
