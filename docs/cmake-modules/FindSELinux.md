# FindSELinux

Find the SELinux library.

Module defines the following `IMPORTED` target(s):

* `SELinux::SELinux` - The package library, if found.

Result variables:

* `SELinux_FOUND` - Whether the package has been found.
* `SELinux_INCLUDE_DIRS` - Include directories needed to use this package.
* `SELinux_LIBRARIES` - Libraries needed to link to the package library.
* `SELinux_VERSION` - Package version, if found.

Cache variables:

* `SELinux_INCLUDE_DIR` - Directory containing package library headers.
* `SELinux_LIBRARY` - The path to the package library.

Hints:

The `SELinux_ROOT` variable adds custom search path.
