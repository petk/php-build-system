<!-- This is auto-generated file. -->
* Source code: [Zend/cmake/CheckMMAlignment.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/CheckMMAlignment.cmake)

Test and set the alignment defines for the Zend memory manager (`ZEND_MM`). This
also does the logarithmic test.

## Cache variables

* `ZEND_MM_ALIGNMENT`
* `ZEND_MM_ALIGNMENT_LOG2`
* `ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT`

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckMMAlignment.cmake)
```
