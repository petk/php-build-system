# FindWebP

See: [FindWebP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindWebP.cmake)

## Basic usage

```cmake
include(cmake/FindWebP.cmake)
```

Find the libwebp library.

Module defines the following `IMPORTED` target(s):

* `WebP::WebP` - The package library, if found.

Result variables:

* `WebP_FOUND` - Whether the package has been found.
* `WebP_INCLUDE_DIRS` - Include directories needed to use this package.
* `WebP_LIBRARIES` - Libraries needed to link to the package library.
* `WebP_VERSION` - Package version, if found.

Cache variables:

* `WebP_INCLUDE_DIR` - Directory containing package library headers.
* `WebP_LIBRARY` - The path to the package library.

Hints:

The `WebP_ROOT` variable adds custom search path.
