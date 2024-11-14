# FindBerkeleyDB

See: [FindBerkeleyDB.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindBerkeleyDB.cmake)

## Basic usage

```cmake
include(cmake/FindBerkeleyDB.cmake)
```

Find the Berkeley DB library.

Module defines the following `IMPORTED` target(s):

* `BerkeleyDB::BerkeleyDB` - The package library, if found.

## Result variables

* `BerkeleyDB_FOUND` - Whether the package has been found.
* `BerkeleyDB_INCLUDE_DIRS`- Include directories needed to use this package.
* `BerkeleyDB_LIBRARIES`- Libraries needed to link to the package library.
* `BerkeleyDB_VERSION` - Package version, if found.

## Cache variables

* `BerkeleyDB_INCLUDE_DIR` - Directory containing package library headers.
* `BerkeleyDB_LIBRARY` - The path to the package library.
* `BerkeleyDB_DB1_INCLUDE_DIR` - Directory containing headers for DB1 emulation
  support in Berkeley DB.

## Hints

* The `BerkeleyDB_ROOT` variable adds custom search path.
* Set `BerkeleyDB_USE_DB1` to `TRUE` before calling `find_package(BerkeleyDB)`
  to enable the Berkeley DB 1.x support/emulation.
