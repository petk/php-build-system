<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindEditline.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindEditline.cmake)

# FindEditline

Finds the Editline library:

```cmake
find_package(Editline)
```

## Imported targets

This module defines the following imported targets:

* `Editline::Editline` - The Editline library, if found.

## Result variables

* `Editline_FOUND` - Whether the package has been found.
* `Editline_INCLUDE_DIRS` - Include directories needed to use this package.
* `Editline_LIBRARIES` - Libraries needed to link to the package library.
* `Editline_VERSION` - Package version, if found.

## Cache variables

* `Editline_INCLUDE_DIR` - Directory containing package library headers.
* `Editline_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Editline)
target_link_libraries(example PRIVATE Editline::Editline)
```

## Customizing search locations

To customize where to look for the Editline package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `EDITLINE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Editline;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DEDITLINE_ROOT=/opt/Editline \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
