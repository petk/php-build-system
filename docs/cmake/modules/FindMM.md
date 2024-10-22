# FindMM

See: [FindMM.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindMM.cmake)

Find the mm library.

Module defines the following `IMPORTED` target(s):

* `MM::MM` - The package library, if found.

Result variables:

* `MM_FOUND` - Whether the package has been found.
* `MM_INCLUDE_DIRS` - Include directories needed to use this package.
* `MM_LIBRARIES` - Libraries needed to link to the package library.

Cache variables:

* `MM_INCLUDE_DIR` - Directory containing package library headers.
* `MM_LIBRARY` - The path to the package library.

Hints:

The `MM_ROOT` variable adds custom search path.
