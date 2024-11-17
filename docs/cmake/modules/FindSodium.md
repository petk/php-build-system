<!-- This is auto-generated file. -->
# FindSodium

* Module source code: [FindSodium.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSodium.cmake)

Find the Sodium library (libsodium).

Module defines the following `IMPORTED` target(s):

* `Sodium::Sodium` - The package library, if found.

Result variables:

* `Sodium_FOUND` - Whether the package has been found.
* `Sodium_INCLUDE_DIRS` - Include directories needed to use this package.
* `Sodium_LIBRARIES` - Libraries needed to link to the package library.
* `Sodium_VERSION` - Package version, if found.

Cache variables:

* `Sodium_INCLUDE_DIR` - Directory containing package library headers.
* `Sodium_LIBRARY` - The path to the package library.

Hints:

The `Sodium_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(Sodium)
```

## Customizing search locations

To customize where to look for the Sodium package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SODIUM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/Sodium;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DSODIUM_ROOT=/opt/Sodium \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
