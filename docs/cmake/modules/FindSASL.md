# FindSASL

See: [FindSASL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSASL.cmake)

## Basic usage

```cmake
find_package(SASL)
```

Find the SASL library.

Module defines the following `IMPORTED` target(s):

* `SASL::SASL` - The package library, if found.

Result variables:

* `SASL_FOUND` - Whether the package has been found.
* `SASL_INCLUDE_DIRS` - Include directories needed to use this package.
* `SASL_LIBRARIES` - Libraries needed to link to the package library.
* `SASL_VERSION` - Package version, if found.

Cache variables:

* `SASL_INCLUDE_DIR` - Directory containing package library headers.
* `SASL_LIBRARY` - The path to the package library.

Hints:

The `SASL_ROOT` variable adds custom search path.
