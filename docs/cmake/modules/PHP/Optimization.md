<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/Optimization.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Optimization.cmake)

# PHP/Optimization

Enable interprocedural optimization (IPO/LTO) on all targets, if supported.

This adds linker flag `-flto` if it is supported by the compiler to run standard
link-time optimizer.

It can be also controlled more granular with the
`CMAKE_INTERPROCEDURAL_OPTIMIZATION_<CONFIG>` variables based on the build type.

This module also checks whether IPO/LTO can be enabled based on the PHP
configuration (due to global register variables) and compiler/platform.

https://cmake.org/cmake/help/latest/prop_tgt/INTERPROCEDURAL_OPTIMIZATION.html

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/Optimization)
```
