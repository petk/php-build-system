# Fibers

See: [Fibers.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/Fibers.cmake)

## Basic usage

```cmake
include(cmake/Fibers.cmake)
```

Check if Fibers can be used.

This module adds Boost fiber assembly files support if available for the
platform, otherwise it checks if ucontext can be used.

## Control variables

* `ZEND_FIBER_ASM`

  Whether to use Boost fiber assembly files.

## Cache variables

* `ZEND_FIBER_UCONTEXT`

  Whether `<ucontext.h>` header file is available and should be used.

## Interface library

* `Zend::Fibers`

  Interface library using Boost fiber assembly files and compile options if
  available.
