# PHP/CheckFlushIo

See: [CheckFlushIo.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckFlushIo.cmake)

## Basic usage

```cmake
include(PHP/CheckFlushIo)
```

Check if flush should be called explicitly after buffered io.

Cache variables:

* `HAVE_FLUSHIO`
  Whether flush should be called explicitly after a buffered io.
