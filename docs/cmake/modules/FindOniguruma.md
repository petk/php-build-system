<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindOniguruma.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindOniguruma.cmake)

# FindOniguruma

Finds the Oniguruma library:

```cmake
find_package(Oniguruma)
```

## Imported targets

This module defines the following imported targets:

* `Oniguruma::Oniguruma` - The package library, if Oniguruma is found.

## Result variables

* `Oniguruma_FOUND` - Whether the package has been found.
* `Oniguruma_INCLUDE_DIRS` - Include directories needed to use this package.
* `Oniguruma_LIBRARIES` - Libraries needed to link to the package library.
* `Oniguruma_VERSION` - Package version, if found.

## Cache variables

* `Oniguruma_INCLUDE_DIR` - Directory containing package library headers.
* `Oniguruma_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Oniguruma)
target_link_libraries(example PRIVATE Oniguruma::Oniguruma)
```

## Customizing search locations

To customize where to look for the Oniguruma package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ONIGURUMA_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Oniguruma;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DONIGURUMA_ROOT=/opt/Oniguruma \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
