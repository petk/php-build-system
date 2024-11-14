# CheckStackLimit

See: [CheckStackLimit.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/CheckStackLimit.cmake)

## Basic usage

```cmake
include(cmake/CheckStackLimit.cmake)
```

Check whether the stack grows downwards. Assumes contiguous stack.

Cache variables:

* `ZEND_CHECK_STACK_LIMIT`
  Whether checking the stack limit is supported.
