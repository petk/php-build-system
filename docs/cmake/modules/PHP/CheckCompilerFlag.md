# PHP/CheckCompilerFlag

See: [CheckCompilerFlag.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckCompilerFlag.cmake)

Check whether the compiler supports given compile option.

CMake's `CheckCompilerFlag` module and its `check_compiler_flag()` macro, at the
time of writing, do not support certain edge cases for certain compilers. This
module aims to address these issues to make checking compile options easier and
more intuitive, while still providing similar functionality on top of CMake's
`CheckCompilerFlag`.

Bypasses:

* Compile options to disable warnings (`-Wno-*`)

  When checking the `-Wno-*` flags, some compilers (GCC, Oracle Developer Studio
  compiler, and most likely some others) don't issue any diagnostic message when
  encountering unsupported `-Wno-*` flag. This modules checks for their opposite
  compile option instead (`-W*`). For example, the silent `-Wno-*` compile flags
  behavior was introduced since GCC 4.4:
  https://gcc.gnu.org/gcc-4.4/changes.html

  See: https://gitlab.kitware.com/cmake/cmake/-/issues/26228

Module exposes the following function:

```cmake
php_check_compiler_flag(<lang> <flag> <result_var>)
```

Check that the <flag> is accepted by the <lang> compiler without issuing any
diagnostic message. The result is stored in an internal cache entry named
`<result_var>`. The language `<lang>` can be one of the supported languages by
the CMake's `CheckCompilerFlag` module.

For example:

```cmake
include(PHP/CheckCompilerFlag)

php_check_compiler_flag(C -Wno-clobbered PHP_HAVE_WNO_CLOBBERED)
```
