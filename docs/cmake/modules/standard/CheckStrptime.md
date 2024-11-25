<!-- This is auto-generated file. -->
* Source code: [ext/standard/cmake/CheckStrptime.cmake](https://github.com/petk/php-build-system/blob/master/cmake/ext/standard/cmake/CheckStrptime.cmake)

# CheckStrptime

Check `strptime()` and its declaration.

Note: This module is obsolete. PHP `strptime()` is deprecated as of PHP 8.1.0.

## Cache variables

* `HAVE_STRPTIME`

  Whether `strptime()` is available.

## Result variables

* `HAVE_DECL_STRPTIME`

  Whether `strptime()` is declared.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckStrptime.cmake)
```
