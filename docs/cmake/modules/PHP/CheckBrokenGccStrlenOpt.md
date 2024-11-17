<!-- This is auto-generated file. -->
# PHP/CheckBrokenGccStrlenOpt

* Module source code: [CheckBrokenGccStrlenOpt.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckBrokenGccStrlenOpt.cmake)

Early GCC 8 versions shipped with a strlen() optimization bug, so it didn't
properly handle the `char val[1]` struct hack. Fixed in GCC 8.3. If below check
is successful the -fno-optimize-strlen compiler flag should be added.
See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=86914

## Cache variables

* `PHP_HAVE_BROKEN_OPTIMIZE_STRLEN`
  Whether GCC has broken strlen() optimization.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckBrokenGccStrlenOpt)
```
