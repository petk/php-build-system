# FindPCRE

See: [FindPCRE.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPCRE.cmake)

## Basic usage

```cmake
include(cmake/FindPCRE.cmake)
```

Find the PCRE library.

Module defines the following `IMPORTED` target(s):

* `PCRE::PCRE` - The package library, if found.

Result variables:

* `PCRE_FOUND` - Whether the package has been found.
* `PCRE_INCLUDE_DIRS` - Include directories needed to use this package.
* `PCRE_LIBRARIES` - Libraries needed to link to the package library.
* `PCRE_VERSION` - Package version, if found.

Cache variables:

* `PCRE_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE_LIBRARY` - The path to the package library.

Hints:

The `PCRE_ROOT` variable adds custom search path.
