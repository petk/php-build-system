# PHP/CheckTimeR

See: [CheckTimeR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckTimeR.cmake)

## Basic usage

```cmake
include(PHP/CheckTimeR)
```

Check type of reentrant time-related functions. Type can be: irix, hpux or
POSIX.

Cache variables:

  PHP_HPUX_TIME_R
    Whether HP-UX 10.x is used.
  PHP_IRIX_TIME_R
    Whether IRIX-style functions are used.
