<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/ThreadSafety.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/ThreadSafety.cmake)

# PHP/ThreadSafety

This module checks whether the PHP thread safety, a.k.a. ZTS (Zend thread
safety) should be enabled:

```cmake
include(PHP/ThreadSafety)
```

## Result variables

* `ZTS`

  Whether PHP thread safety is enabled.

## Custom CMake properties

* `PHP_THREAD_SAFETY`

  When thread safety is enabled (either by the configuration variable
  `PHP_THREAD_SAFETY` or automatically by the `apache2handler` PHP SAPI module),
  also a custom target property `PHP_THREAD_SAFETY` is added to the
  `PHP::config` target, which can be then used in generator expressions during
  the generation phase to determine thread safety enabled from the configuration
  phase. For example, the `PHP_EXTENSION_DIR` configuration variable needs to be
  set depending on the thread safety.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/ThreadSafety)
```
