# Zend/CheckFloatPrecision

See: [CheckFloatPrecision.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/Zend/CheckFloatPrecision.cmake)

Check for x87 floating point internal precision control.

See: https://wiki.php.net/rfc/rounding

Cache variables:

* `HAVE__FPU_SETCW`
  Whether `_FPU_SETCW` is usable.
* `HAVE_FPSETPREC`
  Whether `fpsetprec` is present and usable.
* `HAVE__CONTROLFP`
  Whether `_controlfp` is present and usable.
* `HAVE__CONTROLFP_S`
  Whether `_controlfp_s` is present and usable.
* `HAVE_FPU_INLINE_ASM_X86`
  Whether FPU control word can be manipulated by inline assembler.
