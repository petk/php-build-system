# FindCdb

See: [FindCdb.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindCdb.cmake)

Find the cdb library.

Module defines the following `IMPORTED` target(s):

* `Cdb::Cdb` - The package library, if found.

Result variables:

* `Cdb_FOUND` - Whether the package has been found.
* `Cdb_INCLUDE_DIRS` - Include directories needed to use this package.
* `Cdb_LIBRARIES` - Libraries needed to link to the package library.
* `Cdb_VERSION` - Package version, if found.

Cache variables:

* `Cdb_INCLUDE_DIR` - Directory containing package library headers.
* `Cdb_LIBRARY` - The path to the package library.

Hints:

The `Cdb_ROOT` variable adds custom search path.
