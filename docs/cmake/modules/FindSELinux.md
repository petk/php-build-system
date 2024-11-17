<!-- This is auto-generated file. -->
# FindSELinux

* Module source code: [FindSELinux.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSELinux.cmake)

Find the SELinux library.

Module defines the following `IMPORTED` target(s):

* `SELinux::SELinux` - The package library, if found.

Result variables:

* `SELinux_FOUND` - Whether the package has been found.
* `SELinux_INCLUDE_DIRS` - Include directories needed to use this package.
* `SELinux_LIBRARIES` - Libraries needed to link to the package library.
* `SELinux_VERSION` - Package version, if found.

Cache variables:

* `SELinux_INCLUDE_DIR` - Directory containing package library headers.
* `SELinux_LIBRARY` - The path to the package library.

Hints:

The `SELinux_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(SELinux)
```

## Customizing search locations

To customize where to look for the SELinux package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SELINUX_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/SELinux;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DSELINUX_ROOT=/opt/SELinux \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
