<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindValgrind.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindValgrind.cmake)

# FindValgrind

Find Valgrind.

Module defines the following `IMPORTED` target(s):

* `Valgrind::Valgrind` - The package library, if found.

## Result variables

* `Valgrind_FOUND` - Whether the package has been found.
* `Valgrind_INCLUDE_DIRS` - Include directories needed to use this package.

## Cache variables

* `Valgrind_INCLUDE_DIR` - Directory containing package library headers.

## Usage

```cmake
# CMakeLists.txt
find_package(Valgrind)
```

## Customizing search locations

To customize where to look for the Valgrind package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `VALGRIND_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Valgrind;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DVALGRIND_ROOT=/opt/Valgrind \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
