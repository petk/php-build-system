# FindLMDB

See: [FindLMDB.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindLMDB.cmake)

Find the LMDB library.

Module defines the following `IMPORTED` target(s):

* `LMDB::LMDB` - The package library, if found.

## Result variables

* `LMDB_FOUND` - Whether the package has been found.
* `LMDB_INCLUDE_DIRS` - Include directories needed to use this package.
* `LMDB_LIBRARIES` - Libraries needed to link to the package library.
* `LMDB_VERSION` - Package version, if found.

## Cache variables

* `LMDB_INCLUDE_DIR` - Directory containing package library headers.
* `LMDB_LIBRARY` - The path to the package library.

## Hints

* The `LMDB_ROOT` variable adds custom search path.
