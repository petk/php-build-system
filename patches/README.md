# Patches for php-src

This is a collection of patch files for various PHP versions in order to use
CMake.

## PHP 8.4

* `cmake.patch`

  Overall CMake specific changes.

* `dmalloc.patch`

  See https://github.com/php/php-src/pull/8465

## PHP 8.3

* `cmake.patch`

  Overall CMake specific changes.

* `aspell.patch`

  Patch for using GNU Aspell library without the old and deprecated pspell
  interface.

* `dmalloc.patch`

  See https://github.com/php/php-src/pull/8465

* `fopencookie.patch`

  See https://github.com/php/php-src/pull/12236
