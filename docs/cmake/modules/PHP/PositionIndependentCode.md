<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/PositionIndependentCode.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/PositionIndependentCode.cmake)

# PHP/PositionIndependentCode

Check whether to enable the `POSITION_INDEPENDENT_CODE` or not for all targets.
The SHARED and MODULE targets have PIC enabled regardless of this option.

https://cmake.org/cmake/help/latest/variable/CMAKE_POSITION_INDEPENDENT_CODE.html

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/PositionIndependentCode)
```
