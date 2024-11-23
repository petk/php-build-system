<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckTimeR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckTimeR.cmake)

# PHP/CheckTimeR

Check type of reentrant time-related functions. Type can be: irix, hpux or
POSIX.

## Cache variables

  PHP_HPUX_TIME_R
    Whether HP-UX 10.x is used.
  PHP_IRIX_TIME_R
    Whether IRIX-style functions are used.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckTimeR)
```
