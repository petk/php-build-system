# FindFFI

See: [FindFFI.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindFFI.cmake)

Find the FFI library.

Module defines the following `IMPORTED` target(s):

* `FFI::FFI` - The package library, if found.

Result variables:

* `FFI_FOUND` - Whether the package has been found.
* `FFI_INCLUDE_DIRS` - Include directories needed to use this package.
* `FFI_LIBRARIES` - Libraries needed to link to the package library.
* `FFI_VERSION` - Package version, if found.

Cache variables:

* `FFI_INCLUDE_DIR` - Directory containing package library headers.
* `FFI_LIBRARY` - The path to the package library.

Hints:

The `FFI_ROOT` variable adds custom search path.
