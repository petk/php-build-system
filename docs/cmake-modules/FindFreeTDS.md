# FindFreeTDS

See: [FindFreeTDS.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindFreeTDS.cmake)

Find the FreeTDS set of libraries.

Module defines the following `IMPORTED` target(s):

* `FreeTDS::FreeTDS` - The package library, if found.

Result variables:

* `FreeTDS_FOUND` - Whether the package has been found.
* `FreeTDS_INCLUDE_DIRS` - Include directories needed to use this package.
* `FreeTDS_LIBRARIES` - Libraries needed to link to the package library.

Cache variables:

* `FreeTDS_INCLUDE_DIR` - Directory containing package library headers.
* `FreeTDS_LIBRARY` - The path to the package library.

Hints:

The `FreeTDS_ROOT` variable adds custom search path.
