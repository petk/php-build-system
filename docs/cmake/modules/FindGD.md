<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindGD.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGD.cmake)

# FindGD

Finds the GD library:

```cmake
find_package(GD [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `GD::GD` - The package library, if found.

## Result variables

This module defines the following variables:

* `GD_FOUND` - Boolean indicating whether (the requested version of) package was
  found.
* `GD_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `GD_INCLUDE_DIR` - Directory containing package library headers.
* `GD_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(GD)
target_link_libraries(example PRIVATE GD::GD)
```

## Customizing search locations

To customize where to look for the GD package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `GD_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/GD;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DGD_ROOT=/opt/GD \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
