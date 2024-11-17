<!-- This is auto-generated file. -->
# CheckStrerrorR

* Module source code: [CheckStrerrorR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/CheckStrerrorR.cmake)

Check for `strerror_r()`, and if its a POSIX-compatible or a GNU-specific
version.

Cache variables:

* `HAVE_STRERROR_R`
  Whether `strerror_r()` is available.
* `STRERROR_R_CHAR_P`
  Whether `strerror_r()` returns a `char *` message, otherwise it returns an
  `int` error number.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckStrerrorR.cmake)
```
