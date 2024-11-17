<!-- This is auto-generated file. -->
# PHP/CheckReentrantFunctions

* Module source code: [CheckReentrantFunctions.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckReentrantFunctions.cmake)

Check for reentrant functions and their declarations.

Some systems didn't declare some reentrant functions if `_REENTRANT` was not
defined. This is mostly obsolete and is intended specifically for the PHP code.
The CMake's `check_symbol_exists()` is sufficient to check for reentrant
functions on current systems and this module might be obsolete in the future.

## Cache variables

* `HAVE_LOCALTIME_R`
    Whether `localtime_r()` is available.
* `MISSING_LOCALTIME_R_DECL`
    Whether `localtime_r()` is not declared.
* `HAVE_GMTIME_R`
    Whether `gmtime_r()` is available.
* `MISSING_GMTIME_R_DECL`
    Whether `gmtime_r()` is not declared.
* `HAVE_ASCTIME_R`
    Whether `asctime_r()` is available.
* `MISSING_ASCTIME_R_DECL`
    Whether `asctime_r()` is not declared.
* `HAVE_CTIME_R`
    Whether `ctime_r()` is available.
* `MISSING_CTIME_R_DECL`
    Whether `ctime_r()` is not declared.
* `HAVE_STRTOK_R`
    Whether `strtok_r()` is available.
* `MISSING_STRTOK_R_DECL`
    Whether `strtok_r()` is not declared.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckReentrantFunctions)
```
