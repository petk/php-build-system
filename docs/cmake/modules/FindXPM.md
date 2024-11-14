# FindXPM

See: [FindXPM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindXPM.cmake)

## Basic usage

```cmake
find_package(XPM)
```

Find the libXpm library.

Module defines the following `IMPORTED` target(s):

* `XPM::XPM` - The libXpm library, if found.

Result variables:

* `XPM_FOUND` - Whether the package has been found.
* `XPM_INCLUDE_DIRS` - Include directories needed to use this package.
* `XPM_LIBRARIES` - Libraries needed to link to the package library.
* `XPM_VERSION` - Package version, if found.

Cache variables:

* `XPM_INCLUDE_DIR` - Directory containing package library headers.
* `XPM_LIBRARY` - The path to the package library.

Hints:

The `XPM_ROOT` variable adds custom search path.
