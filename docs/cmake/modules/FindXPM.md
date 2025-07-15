<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindXPM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindXPM.cmake)

# FindXPM

Finds the libXpm library:

```cmake
find_package(XPM)
```

## Imported targets

This module defines the following imported targets:

* `XPM::XPM` - The libXpm library, if found.

## Result variables

* `XPM_FOUND` - Whether the package has been found.
* `XPM_INCLUDE_DIRS` - Include directories needed to use this package.
* `XPM_LIBRARIES` - Libraries needed to link to the package library.
* `XPM_VERSION` - Package version, if found.

## Cache variables

* `XPM_INCLUDE_DIR` - Directory containing package library headers.
* `XPM_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(XPM)
target_link_libraries(example PRIVATE XPM::XPM)
```

## Customizing search locations

To customize where to look for the XPM package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `XPM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/XPM;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DXPM_ROOT=/opt/XPM \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
