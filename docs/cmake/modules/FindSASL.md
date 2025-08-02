<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindSASL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSASL.cmake)

# FindSASL

Finds the SASL library:

```cmake
find_package(SASL [<version>] [...])
```

## Imported targets

This module defines the following imported targets:

* `SASL::SASL` - The package library, if found.

## Result variables

* `SASL_FOUND` - Boolean indicating whether the package is found.
* `SASL_VERSION` - The version of package found.

## Cache variables

* `SASL_INCLUDE_DIR` - Directory containing package library headers.
* `SASL_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(SASL)
target_link_libraries(example PRIVATE SASL::SASL)
```

## Customizing search locations

To customize where to look for the SASL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SASL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/SASL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DSASL_ROOT=/opt/SASL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
