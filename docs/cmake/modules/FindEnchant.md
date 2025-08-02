<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindEnchant.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindEnchant.cmake)

# FindEnchant

Finds the Enchant library:

```cmake
find_package(Enchant [<version>] [...])
```

Enchant uses different library names based on the version - `enchant-2` for
version 2.x and `enchant` for earlier versions < 2.0.

## Imported targets

This module defines the following imported targets:

* `Enchant::Enchant` - The package library, if found.

## Result variables

* `Enchant_FOUND` - Boolean indicating whether the package is found.
* `Enchant_VERSION` - The version of package found.

## Cache variables

* `Enchant_INCLUDE_DIR` - Directory containing package library headers.
* `Enchant_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Enchant)
target_link_libraries(example PRIVATE Enchant::Enchant)
```

## Customizing search locations

To customize where to look for the Enchant package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ENCHANT_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Enchant;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DENCHANT_ROOT=/opt/Enchant \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
