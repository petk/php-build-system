<!-- This is auto-generated file. -->
* Source code: [cmake/modules/Findlibzip.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findlibzip.cmake)

# Findlibzip

Finds the libzip library:

```cmake
find_package(libzip [<version>] [...])
```

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

## Imported targets

This module provides the following imported targets:

* `libzip::zip` - The package library, if found.

## Result variables

This module defines the following variables:

* `libzip_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `libzip_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libzip)
target_link_libraries(example PRIVATE libzip::zip)
```

## Customizing search locations

To customize where to look for the libzip package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LIBZIP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/libzip;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DLIBZIP_ROOT=/opt/libzip \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
