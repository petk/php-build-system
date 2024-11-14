# FindCapstone

See: [FindCapstone.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCapstone.cmake)

## Basic usage

```cmake
find_package(Capstone)
```

Find the Capstone library.

Module defines the following `IMPORTED` target(s):

* `Capstone::Capstone` - The package library, if found.

Result variables:

* `Capstone_FOUND` - Whether the package has been found.
* `Capstone_INCLUDE_DIRS` - Include directories needed to use this package.
* `Capstone_LIBRARIES` - Libraries needed to link to the package library.
* `Capstone_VERSION` - Package version, if found.

Cache variables:

* `Capstone_INCLUDE_DIR` - Directory containing package library headers.
* `Capstone_LIBRARY` - The path to the package library.

Hints:

The `Capstone_ROOT` variable adds custom search path.
