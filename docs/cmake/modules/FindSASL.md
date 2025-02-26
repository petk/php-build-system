<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindSASL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSASL.cmake)

# FindSASL

Find the SASL library.

Module defines the following `IMPORTED` target(s):

* `SASL::SASL` - The package library, if found.

## Result variables

* `SASL_FOUND` - Whether the package has been found.
* `SASL_INCLUDE_DIRS` - Include directories needed to use this package.
* `SASL_LIBRARIES` - Libraries needed to link to the package library.
* `SASL_VERSION` - Package version, if found.

## Cache variables

* `SASL_INCLUDE_DIR` - Directory containing package library headers.
* `SASL_LIBRARY` - The path to the package library.

## Usage

```cmake
# CMakeLists.txt
find_package(SASL)
```

## Customizing search locations

To customize where to look for the SASL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SASL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/SASL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DSASL_ROOT=/opt/SASL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
