<!-- This is auto-generated file. -->
* Source code: [cmake/modules/Findlibuhdr.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findlibuhdr.cmake)

# Findlibuhdr

Finds the libuhdr library:

```cmake
find_package(libuhdr [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `libuhdr::libuhdr` - Target encapsulating the package usage requirements,
  available if package was found.

## Result variables

This module defines the following variables:

* `libuhdr_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `libuhdr_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `libuhdr_INCLUDE_DIR` - Directory containing package library headers.
* `libuhdr_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(libuhdr)`:

* `libuhdr_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libuhdr)
target_link_libraries(example PRIVATE libuhdr::libuhdr)
```

## Customizing search locations

To customize where to look for the libuhdr package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LIBUHDR_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/libuhdr;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DLIBUHDR_ROOT=/opt/libuhdr \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
