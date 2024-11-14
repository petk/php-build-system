# Findlibzip

See: [Findlibzip.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findlibzip.cmake)

## Basic usage

```cmake
find_package(libzip)
```

Find the libzip library.

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

Module defines the following `IMPORTED` target(s):

* `libzip::libzip` - The package library, if found.

Result variables:

* `libzip_FOUND` - Whether the package has been found.
* `libzip_INCLUDE_DIRS` - Include directories needed to use this package.
* `libzip_LIBRARIES` - Libraries needed to link to the package library.
* `libzip_VERSION` - Package version, if found.

Cache variables:

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.
* `HAVE_SET_MTIME`
* `HAVE_ENCRYPTION`
* `HAVE_LIBZIP_VERSION`

Hints:

The `libzip_ROOT` variable adds custom search path.
