# FindCrypt

See: [FindCrypt.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCrypt.cmake)

## Basic usage

```cmake
find_package(Crypt)
```

Find the crypt library and run a set of PHP-specific checks if library works.

The Crypt library can be on some systems part of the standard C library. The
crypt() and crypt_r() functions are usually declared in the unistd.h or crypt.h.
The GNU C library removed the crypt library in version 2.39 and replaced it with
the libxcrypt, at the time of writing, located at
https://github.com/besser82/libxcrypt.

Module defines the following `IMPORTED` target(s):

* `Crypt::Crypt` - The package library, if found.

Result variables:

* `Crypt_FOUND` - Whether the package has been found.
* `Crypt_INCLUDE_DIRS` - Include directories needed to use this package.
* `Crypt_LIBRARIES` - Libraries needed to link to the package library.
* `Crypt_VERSION` - Package version, if found.

Cache variables:

* `Crypt_IS_BUILT_IN` - Whether crypt is a part of the C library.
* `Crypt_INCLUDE_DIR` - Directory containing package library headers.
* `Crypt_LIBRARY` - The path to the package library.

Hints:

The `Crypt_ROOT` variable adds custom search path.
