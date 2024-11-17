<!-- This is auto-generated file. -->
# PHP/CheckAVX512

* Module source code: [CheckAVX512.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckAVX512.cmake)

Check whether compiler supports AVX-512 extensions. Note that this is a compiler
check, not a runtime check where further adjustments are done in the php-src C
code to use these extensions.

TODO: Adjust checks for MSVC.

Cache variables:

* `PHP_HAVE_AVX512_SUPPORTS`
  Whether compiler supports AVX-512.
* `PHP_HAVE_AVX512_VBMI_SUPPORTS`
  Whether compiler supports AVX-512 VBMI.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckAVX512)
```
