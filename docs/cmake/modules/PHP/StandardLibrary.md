<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/StandardLibrary.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/StandardLibrary.cmake)

# PHP/StandardLibrary

This module determines the C standard library used for the build:

```cmake
include(PHP/StandardLibrary)
```

## Cache variables

* `PHP_C_STANDARD_LIBRARY`

  Lowercase name of the C standard library:

    * `cosmopolitan`
    * `dietlibc`
    * `glibc`
    * `llvm`
    * `mscrt`
    * `musl`
    * `uclibc`

  If library cannot be determined, it is set to empty string.

* `__MUSL__` - Whether the C standard library is musl.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/StandardLibrary)
```
