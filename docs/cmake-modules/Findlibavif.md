# Findlibavif

Find the libavif library.

This is a helper in case system doesn't have the library's Config find module.

Module defines the following `IMPORTED` target(s):

* `libavif::libavif` - The package library, if found.

Result variables:

* `libavif_FOUND` - Whether the package has been found.
* `libavif_INCLUDE_DIRS` - Include directories needed to use this package.
* `libavif_LIBRARIES` - Libraries needed to link to the package library.
* `libavif_VERSION` - Package version, if found.

Cache variables:

* `libavif_INCLUDE_DIR` - Directory containing package library headers.
* `libavif_LIBRARY` - The path to the package library.

Hints:

The `libavif_ROOT` variable adds custom search path.
