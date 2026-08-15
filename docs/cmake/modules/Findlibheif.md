<!-- This is auto-generated file. -->
* Source code: [cmake/modules/Findlibheif.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findlibheif.cmake)

# Findlibheif

Finds the libheif library:

```cmake
find_package(libheif [<version>] [...])
```

This is a helper find module because the libheif upstream CMake config files
have `ExactVersion` compatibility constraint which isn't useful for finding any
libheif version.

## Imported targets

This module provides the following imported targets:

* `libheif::libheif` - Target encapsulating the package usage requirements,
  available if package was found.

## Result variables

This module defines the following variables:

* `libheif_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `libheif_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `libheif_INCLUDE_DIR` - Directory containing package library headers.
* `libheif_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(libheif)`:

* `libheif_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libheif)
target_link_libraries(example PRIVATE libheif::libheif)
```

## Customizing search locations

To customize where to look for the libheif package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LIBHEIF_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/libheif;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DLIBHEIF_ROOT=/opt/libheif \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
