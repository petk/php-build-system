# PHP/CheckWrite

See: [CheckWrite.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckWrite.cmake)

## Basic usage

```cmake
include(PHP/CheckWrite)
```

Check whether writing to stdout works.

Cache variables:

* `PHP_WRITE_STDOUT`
  Whether `write(2)` works.
