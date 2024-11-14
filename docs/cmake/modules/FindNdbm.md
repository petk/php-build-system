# FindNdbm

See: [FindNdbm.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindNdbm.cmake)

## Basic usage

```cmake
include(cmake/FindNdbm.cmake)
```

Find the ndbm library.

Depending on the system, the nbdm ("new" dbm) can be part of other libraries as
an interface.

* GNU dbm library (GDBM) has a compatibility interface that provides ndbm.h
  header and gdbm_compat library.
* Built into default libraries (C): BSD-based systems, macOS, Solaris.

Module defines the following `IMPORTED` target(s):

* `Ndbm::Ndbm` - The package library, if found.

## Result variables

* `Ndbm_FOUND` - Whether the package has been found.
* `Ndbm_IS_BUILT_IN` - Whether ndbm is a part of the C library.
* `Ndbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Ndbm_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.

## Hints

* The `Ndbm_ROOT` variable adds custom search path.
