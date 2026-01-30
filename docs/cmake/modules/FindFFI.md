<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindFFI.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindFFI.cmake)

# FindFFI

Finds the FFI library:

```cmake
find_package(FFI [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `FFI::FFI` - Target encapsulating the FFI library usage requirements,
  available only if FFI was found.

## Result variables

This module defines the following variables:

* `FFI_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `FFI_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `FFI_INCLUDE_DIR` - Directory containing package library headers.
* `FFI_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(FFI)`:

* `FFI_USE_STATIC_LIBS` - Set this variable to boolean true to search for static
  libraries.

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
