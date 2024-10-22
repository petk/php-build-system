# FindGD

See: [FindGD.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindGD.cmake)

Find the GD library.

Module defines the following `IMPORTED` target(s):

* `GD::GD` - The package library, if found.

Result variables:

* `GD_FOUND` - Whether the package has been found.
* `GD_INCLUDE_DIRS` - Include directories needed to use this package.
* `GD_LIBRARIES` - Libraries needed to link to the package library.
* `GD_VERSION` - Package version, if found.

Cache variables:

* `GD_INCLUDE_DIR` - Directory containing package library headers.
* `GD_LIBRARY` - The path to the package library.

Hints:

The `GD_ROOT` variable adds custom search path.
