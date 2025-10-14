<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindTokyoCabinet.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindTokyoCabinet.cmake)

# FindTokyoCabinet

Finds the Tokyo Cabinet library:

```cmake
find_package(TokyoCabinet [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `TokyoCabinet::TokyoCabinet` - The package library, if found.

## Result variables

This module defines the following variables:

* `TokyoCabinet_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `TokyoCabinet_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

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
