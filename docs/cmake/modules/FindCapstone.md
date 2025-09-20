<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCapstone.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCapstone.cmake)

# FindCapstone

Finds the Capstone library:

```cmake
find_package(Capstone [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Capstone::Capstone` - The package library, if found.

## Result variables

* `Capstone_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `Capstone_VERSION` - The version of package found.

## Cache variables

* `Capstone_INCLUDE_DIR` - Directory containing package library headers.
* `Capstone_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Capstone)
target_link_libraries(example PRIVATE Capstone::Capstone)
```

## Customizing search locations

To customize where to look for the Capstone package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CAPSTONE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Capstone;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCAPSTONE_ROOT=/opt/Capstone \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
