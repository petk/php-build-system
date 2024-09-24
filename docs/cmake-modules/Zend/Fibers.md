# Zend/Fibers

See: [Fibers.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/Zend/Fibers.cmake)

Check if Fibers can be used.

This module adds Boost fiber assembly files support if available for the
platform, otherwise it checks if ucontext can be used.

Interface library:

* `Zend::Fibers`
  Library using Boost fiber assembly files if available.

Cache variables:

* `ZEND_FIBER_UCONTEXT`
  Whether `<ucontext.h>` header file is available and should be used.

Control variables:

* `ZEND_FIBER_ASM`
  Whether to use Boost fiber assembly files.
