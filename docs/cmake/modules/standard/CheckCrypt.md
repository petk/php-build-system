<!-- This is auto-generated file. -->
* Source code: [ext/standard/cmake/CheckCrypt.cmake](https://github.com/petk/php-build-system/blob/master/cmake/ext/standard/cmake/CheckCrypt.cmake)

Check whether the `crypt` library works as expected for PHP by running a set of
PHP-specific checks.

## Cache variables

* HAVE_CRYPT_H
* HAVE_CRYPT
* HAVE_CRYPT_R
* CRYPT_R_CRYPTD
* CRYPT_R_STRUCT_CRYPT_DATA
* CRYPT_R_GNU_SOURCE

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckCrypt.cmake)
```
