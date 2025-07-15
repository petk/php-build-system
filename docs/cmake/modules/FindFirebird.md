<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindFirebird.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindFirebird.cmake)

# FindFirebird

Finds the Firebird library:

```cmake
find_package(Firebird)
```

## Imported targets

This module defines the following imported targets:

* `Firebird::Firebird` - The package library, if found.

## Result variables

* `Firebird_CFLAGS` - A list of CFLAGS as given by the fb_config Firebird
  command-line utility.
* `Firebird_FOUND` - Whether the package has been found.
* `Firebird_INCLUDE_DIRS` - Include directories needed to use this package.
* `Firebird_LIBRARIES` - Libraries needed to link to the package library.
* `Firebird_VERSION` - Version of Firebird if fb-config utility is available.

## Cache variables

* `Firebird_INCLUDE_DIR` - Directory containing package library headers.
* `Firebird_LIBRARY` - The path to the package library.
* `Firebird_CONFIG_EXECUTABLE` - Path to the fb_config Firebird command-line
  utility.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Firebird)
target_link_libraries(example PRIVATE Firebird::Firebird)
```

## Customizing search locations

To customize where to look for the Firebird package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `FIREBIRD_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Firebird;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DFIREBIRD_ROOT=/opt/Firebird \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
