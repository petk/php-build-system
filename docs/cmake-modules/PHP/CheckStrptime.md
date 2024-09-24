# PHP/CheckStrptime

See: [CheckStrptime.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckStrptime.cmake)

Check `strptime()` and its declaration.

Note: This module is obsolete. PHP `strptime()` is deprecated as of PHP 8.1.0.

Cache variables:

* `HAVE_STRPTIME`
  Whether `strptime()` is available.

Result variables:

* `HAVE_DECL_STRPTIME`
  Whether `strptime()` is declared.
