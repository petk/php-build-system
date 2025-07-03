<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckCompilerFlag.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckCompilerFlag.cmake)

# PHP/CheckCompilerFlag

This module checks whether the compiler supports given compile option:

```cmake
include(PHP/CheckCompilerFlag)
```

CMake's `CheckCompilerFlag` module and its `check_compiler_flag()` command, at
the time of writing, do not support certain edge cases for certain compilers.
This module aims to address these issues to make checking compile options easier
and more intuitive, while still providing similar functionality on top of
CMake's `CheckCompilerFlag`.

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

```cmake
php_check_compiler_flag(<lang> <flags> <result-var>)
```

Check that the given flag(s) specified in `<flags>` are accepted by the `<lang>`
compiler without issuing any diagnostic message. The result is stored in an
internal cache entry named `<result-var>`. The language `<lang>` can be one of
the supported languages by the CMake's `CheckCompilerFlag` module. Multiple
flags can be passed as a semicolon-separated list.

# Examples

Usage example:

```cmake
# CMakeLists.txt

include(PHP/CheckCompilerFlag)

php_check_compiler_flag(C -Wno-clobbered PHP_HAS_WNO_CLOBBERED)
```
