# FindDmalloc

See: [FindDmalloc.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDmalloc.cmake)

## Basic usage

```cmake
include(cmake/FindDmalloc.cmake)
```

Find the Dmalloc library.

Module defines the following `IMPORTED` target(s):

* `Dmalloc::Dmalloc` - The package library, if found.

Result variables:

* `Dmalloc_FOUND` - Whether the package has been found.
* `Dmalloc_INCLUDE_DIRS` - Include directories needed to use this package.
* `Dmalloc_LIBRARIES` - Libraries needed to link to the package library.
* `Dmalloc_VERSION` - Package version, if found.

Cache variables:

* `Dmalloc_INCLUDE_DIR` - Directory containing package library headers.
* `Dmalloc_LIBRARY` - The path to the package library.

Hints:

The `Dmalloc_ROOT` variable adds custom search path.
