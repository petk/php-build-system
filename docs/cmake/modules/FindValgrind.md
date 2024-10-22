# FindValgrind

See: [FindValgrind.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindValgrind.cmake)

Find Valgrind.

Module defines the following `IMPORTED` target(s):

* `Valgrind::Valgrind` - The package library, if found.

Result variables:

* `Valgrind_FOUND` - Whether the package has been found.
* `Valgrind_INCLUDE_DIRS` - Include directories needed to use this package.

Cache variables:

* `Valgrind_INCLUDE_DIR` - Directory containing package library headers.
* `HAVE_VALGRIND` - Whether Valgrind is enabled.
* `HAVE_VALGRIND_CACHEGRIND_H` - Whether Cachegrind is available.

Hints:

The `Valgrind_ROOT` variable adds custom search path.
