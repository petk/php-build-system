<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCrypt.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCrypt.cmake)

# FindCrypt

Finds the crypt library and run a set of PHP-specific checks if library works:

```cmake
find_package(Crypt)
```

The Crypt library can be on some systems part of the standard C library. The
crypt() and crypt_r() functions are usually declared in the unistd.h or crypt.h.
The GNU C library removed the crypt library in version 2.39 and replaced it with
the libxcrypt, at the time of writing, located at
https://github.com/besser82/libxcrypt.

## Imported targets

This module defines the following imported targets:

* `Crypt::Crypt` - The package library, if found.

## Result variables

* `Crypt_FOUND` - Whether the package has been found.
* `Crypt_INCLUDE_DIRS` - Include directories needed to use this package.
* `Crypt_LIBRARIES` - Libraries needed to link to the package library.
* `Crypt_VERSION` - Package version, if found.

## Cache variables

* `Crypt_IS_BUILT_IN` - Whether crypt is a part of the C library.
* `Crypt_INCLUDE_DIR` - Directory containing package library headers.
* `Crypt_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Crypt)
target_link_libraries(example PRIVATE Crypt::Crypt)
```

## Customizing search locations

To customize where to look for the Crypt package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CRYPT_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Crypt;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCRYPT_ROOT=/opt/Crypt \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
