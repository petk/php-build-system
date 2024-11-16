# FindDbm

See: [FindDbm.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDbm.cmake)

## Basic usage

```cmake
find_package(Dbm)
```

Find the dbm library.

Depending on the system, the dbm library can be part of other libraries as an
interface.

* GNU dbm library (GDBM) has compatibility interface via gdbm_compatibility but
  it is licensed as GPL 3, which is incompatible with PHP.
* TODO: Built into default libraries (C): Solaris still has some macros
  definitions mapping to internal dbm functions available in the db.h header.
  When defining `DB_DBM_HSEARCH` dbm handler is available as built into C
  library. However, this is museum code and probably relying on a standalone dbm
  package instead should be done without using this artifact. PHP in the past
  already used this and moved the db extension out of the php-src to PECL.

Module defines the following `IMPORTED` target(s):

* `Dbm::Dbm` - The package library, if found.

## Result variables

* `Dbm_FOUND` - Whether the package has been found.
* `Dbm_IS_BUILT_IN` - Whether dbm is a part of the C library.
* `Dbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Dbm_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Dbm_INCLUDE_DIR` - Directory containing package library headers.
* `Dbm_LIBRARY` - The path to the package library.

## Hints

* The `Dbm_ROOT` variable adds custom search path.
