<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindFFI.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindFFI.cmake)

# FindFFI

Finds the FFI library:

```cmake
find_package(FFI)
```

## Imported targets

This module defines the following imported targets:

* `FFI::FFI` - The package library, if found.

## Result variables

* `FFI_FOUND` - Whether the package has been found.
* `FFI_INCLUDE_DIRS` - Include directories needed to use this package.
* `FFI_LIBRARIES` - Libraries needed to link to the package library.
* `FFI_VERSION` - Package version, if found.

## Cache variables

* `FFI_INCLUDE_DIR` - Directory containing package library headers.
* `FFI_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(FFI)
target_link_libraries(example PRIVATE FFI::FFI)
```

## Customizing search locations

To customize where to look for the FFI package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `FFI_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/FFI;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DFFI_ROOT=/opt/FFI \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
