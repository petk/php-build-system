<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindSystemd.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSystemd.cmake)

# FindSystemd

Finds the systemd library (libsystemd):

```cmake
find_package(Systemd)
```

## Imported targets

This module defines the following imported targets:

* `Systemd::Systemd` - The package library, if found.

## Result variables

* `Systemd_FOUND` - Whether the package has been found.
* `Systemd_INCLUDE_DIRS` - Include directories needed to use this package.
* `Systemd_LIBRARIES` - Libraries needed to link to the package library.
* `Systemd_VERSION` - Package version, if found.

## Cache variables

* `Systemd_INCLUDE_DIR` - Directory containing package library headers.
* `Systemd_LIBRARY` - The path to the package library.
* `Systemd_EXECUTABLE` - A systemd command-line tool, if available.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Systemd)
target_link_libraries(example PRIVATE Systemd::Systemd)
```

## Customizing search locations

To customize where to look for the Systemd package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SYSTEMD_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Systemd;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DSYSTEMD_ROOT=/opt/Systemd \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
