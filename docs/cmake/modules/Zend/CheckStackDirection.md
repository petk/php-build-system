<!-- This is auto-generated file. -->
* Source code: [Zend/cmake/CheckStackDirection.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/CheckStackDirection.cmake)

# CheckStackDirection

Check whether the stack grows downwards. Assumes contiguous stack.

## Cache variables

* `ZEND_CHECK_STACK_LIMIT`

  Whether checking the stack limit is supported.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckStackDirection.cmake)
```
