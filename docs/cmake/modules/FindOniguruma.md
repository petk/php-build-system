<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindOniguruma.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindOniguruma.cmake)

# FindOniguruma

Finds the Oniguruma library:

```cmake
find_package(Oniguruma [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Oniguruma::Oniguruma` - The package library, if Oniguruma is found.

## Result variables

This module defines the following variables:

* `Oniguruma_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `Oniguruma_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

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
