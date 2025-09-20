<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindGMP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGMP.cmake)

# FindGMP

Finds the GMP library:

```cmake
find_package(GMP [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `GMP::GMP` - The package library, if found.

## Result variables

* `GMP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `GMP_VERSION` - The version of package found.

## Cache variables

* `GMP_INCLUDE_DIR` - Directory containing package library headers.
* `GMP_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(GMP)
target_link_libraries(example PRIVATE GMP::GMP)
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
