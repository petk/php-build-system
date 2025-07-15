<!-- This is auto-generated file. -->
* Source code: [cmake/modules/Findlibzip.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findlibzip.cmake)

# Findlibzip

Finds the libzip library:

```cmake
find_package(libzip)
```

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

## Imported targets

This module defines the following imported targets:

* `libzip::libzip` - The package library, if found.

## Result variables

* `libzip_FOUND` - Whether the package has been found.
* `libzip_INCLUDE_DIRS` - Include directories needed to use this package.
* `libzip_LIBRARIES` - Libraries needed to link to the package library.
* `libzip_VERSION` - Package version, if found.

## Cache variables

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.
* `HAVE_SET_MTIME`
* `HAVE_ENCRYPTION`
* `HAVE_LIBZIP_VERSION`

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libzip)
target_link_libraries(example PRIVATE libzip::libzip)
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
