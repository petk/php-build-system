<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindMM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMM.cmake)

# FindMM

Finds the mm library:

```cmake
find_package(MM)
```

## Imported targets

This module provides the following imported targets:

* `MM::MM` - The package library, if found.

## Result variables

* `MM_FOUND` - Boolean indicating whether the package is found.

## Cache variables

* `MM_INCLUDE_DIR` - Directory containing package library headers.
* `MM_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(MM)
target_link_libraries(example PRIVATE MM::MM)
```

## Customizing search locations

To customize where to look for the MM package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `MM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/MM;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DMM_ROOT=/opt/MM \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
