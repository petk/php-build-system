<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindFreeTDS.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindFreeTDS.cmake)

# FindFreeTDS

Finds the FreeTDS set of libraries:

```cmake
find_package(FreeTDS)
```

## Imported targets

This module provides the following imported targets:

* `FreeTDS::FreeTDS` - The package library, if found.

## Result variables

* `FreeTDS_FOUND` - Boolean indicating whether the package was found.

## Cache variables

* `FreeTDS_INCLUDE_DIR` - Directory containing package library headers.
* `FreeTDS_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(FreeTDS)
target_link_libraries(example PRIVATE FreeTDS::FreeTDS)
```

## Customizing search locations

To customize where to look for the FreeTDS package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `FREETDS_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/FreeTDS;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DFREETDS_ROOT=/opt/FreeTDS \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
