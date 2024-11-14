# FindSodium

See: [FindSodium.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSodium.cmake)

## Basic usage

```cmake
find_package(Sodium)
```

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
