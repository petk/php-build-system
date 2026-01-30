<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindXPM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindXPM.cmake)

# FindXPM

Finds the libXpm library:

```cmake
find_package(XPM [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `XPM::XPM` - Target encapsulating the libXpm library usage requirements,
  available only if libXpm was found.

## Result variables

This module defines the following variables:

* `XPM_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `XPM_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `XPM_INCLUDE_DIR` - Directory containing package library headers.
* `XPM_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(XPM)`:

* `XPM_USE_STATIC_LIBS` - Set this variable to boolean true to search for static
  libraries.

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
