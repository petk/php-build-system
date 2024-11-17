<!-- This is auto-generated file. -->
# FindEnchant

* Module source code: [FindEnchant.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindEnchant.cmake)

Find the Enchant library.

Enchant uses different library names based on the version - `enchant-2` for
version 2.x and `enchant` for earlier versions < 2.0.

Module defines the following `IMPORTED` target(s):

* `Enchant::Enchant` - The package library, if found.

## Result variables

* `Enchant_FOUND` - Whether the package has been found.
* `Enchant_INCLUDE_DIRS` - Include directories needed to use this package.
* `Enchant_LIBRARIES` - Libraries needed to link to the package library.
* `Enchant_VERSION` - Package version, if found.

## Cache variables

* `Enchant_INCLUDE_DIR` - Directory containing package library headers.
* `Enchant_LIBRARY` - The path to the package library.

## Basic usage

```cmake
# CMakeLists.txt
find_package(Enchant)
```

## Customizing search locations

To customize where to look for the Enchant package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ENCHANT_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/Enchant;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DENCHANT_ROOT=/opt/Enchant \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
