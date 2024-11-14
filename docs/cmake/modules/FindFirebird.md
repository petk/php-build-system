# FindFirebird

See: [FindFirebird.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindFirebird.cmake)

## Basic usage

```cmake
include(cmake/FindFirebird.cmake)
```

Find the Firebird library.

Module defines the following `IMPORTED` target(s):

* `Firebird::Firebird` - The package library, if found.

Result variables:

* `Firebird_CFLAGS` - A list of CFLAGS as given by the fb_config Firebird
  command-line utility.
* `Firebird_FOUND` - Whether the package has been found.
* `Firebird_INCLUDE_DIRS` - Include directories needed to use this package.
* `Firebird_LIBRARIES` - Libraries needed to link to the package library.
* `Firebird_VERSION` - Version of Firebird if fb-config utility is available.

Cache variables:

* `Firebird_INCLUDE_DIR` - Directory containing package library headers.
* `Firebird_LIBRARY` - The path to the package library.
* `Firebird_CONFIG_EXECUTABLE` - Path to the fb_config Firebird command-line
  utility.

Hints:

The `Firebird_ROOT` variable adds custom search path.
