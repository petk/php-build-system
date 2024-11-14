# PHP/CheckByteOrder

See: [CheckByteOrder.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckByteOrder.cmake)

## Basic usage

```cmake
include(PHP/CheckByteOrder)
```

Check whether system byte ordering is big-endian.

Cache variables:

* `WORDS_BIGENDIAN`
