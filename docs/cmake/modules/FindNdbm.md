# FindNdbm

See: [FindNdbm.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindNdbm.cmake)

Find the ndbm library.

Depending on the system, the nbdm ("new" dbm) library can be part of other
libraries as an interface. For example, GNU dbm library (GDBM) has a
compatibility interface that provides ndbm.h header and gdbm_compat library.

Module defines the following `IMPORTED` target(s):

* `Ndbm::Ndbm` - The package library, if found.

## Result variables

* `Ndbm_FOUND` - Whether the package has been found.
* `Ndbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Ndbm_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.

## Hints

* The `Ndbm_ROOT` variable adds custom search path.
