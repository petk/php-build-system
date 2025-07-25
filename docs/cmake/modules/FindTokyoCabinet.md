<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindTokyoCabinet.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindTokyoCabinet.cmake)

# FindTokyoCabinet

Finds the Tokyo Cabinet library:

```cmake
find_package(TokyoCabinet)
```

## Imported targets

This module defines the following imported targets:

* `TokyoCabinet::TokyoCabinet` - The package library, if found.

## Result variables

* `TokyoCabinet_FOUND` - Whether the package has been found.
* `TokyoCabinet_INCLUDE_DIRS` - Include directories needed to use this package.
* `TokyoCabinet_LIBRARIES` - Libraries needed to link to the package library.
* `TokyoCabinet_VERSION` - Package version, if found.

## Cache variables

* `TokyoCabinet_INCLUDE_DIR` - Directory containing package library headers.
* `TokyoCabinet_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(TokyoCabinet)
target_link_libraries(example PRIVATE TokyoCabinet::TokyoCabinet)
```

## Customizing search locations

To customize where to look for the TokyoCabinet package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `TOKYOCABINET_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/TokyoCabinet;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DTOKYOCABINET_ROOT=/opt/TokyoCabinet \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
