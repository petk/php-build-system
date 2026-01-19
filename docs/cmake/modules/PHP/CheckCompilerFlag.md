<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckCompilerFlag.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckCompilerFlag.cmake)

# PHP/CheckCompilerFlag

This module provides a command to check whether the compiler supports given
compile option.

Load this module in a CMake project with:

```cmake
include(PHP/CheckCompilerFlag)
```

CMake's [`CheckCompilerFlag`](https://cmake.org/cmake/help/latest/module/CheckCompilerFlag.html)
module, at the time of writing, does not support certain edge cases for certain
compilers. This module aims to address these issues to make checking compile
options easier and more intuitive, while still providing similar functionality
on top of CMake's `CheckCompilerFlag` module.

Additional functionality of this module:

* Supports checking the `-Wno-*` compile options (options that disable
  warnings).

  When checking the `-Wno-*` flags, some compilers (GCC, Oracle Developer Studio
  compiler, and most likely some others) don't issue any diagnostic message when
  encountering unsupported `-Wno-*` flag. This modules checks for their opposite
  compile option instead (`-W*`). For example, the silent `-Wno-*` compile flags
  behavior was introduced since GCC 4.4:
  https://gcc.gnu.org/gcc-4.4/changes.html

  See: https://gitlab.kitware.com/cmake/cmake/-/issues/26228

## Commands

This module provides the following command:

### `php_check_compiler_flag()`

Check that the given flag(s) are accepted by the specified language compiler
without issuing any diagnostic message:

```cmake
php_check_compiler_flag(<lang> <flags> <result-var>)
```

The arguments are:

* `<lang>` - The language of the compiler to use for the check. The language can
  be one of the supported languages by the CMake's `CheckCompilerFlag` module.

* `<flags>` - One or more compiler options being checked. Pass multiple flags
  as a semicolon-separated list.

* `<result-var>` - The name of the internal cache entry where the result is
  stored in.

## Examples

Usage example:

```cmake
# CMakeLists.txt

include(PHP/CheckCompilerFlag)

php_check_compiler_flag(C -Wno-clobbered PHP_HAS_WNO_CLOBBERED)
```
