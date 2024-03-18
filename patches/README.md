# Patches for php-src

This is a collection of patch files for various PHP versions in order to use
CMake.

## PHP 8.4

* `cmake.patch`

  Overall CMake specific changes.

* `dmalloc.patch`

  See https://github.com/php/php-src/pull/8465

* `docs.patch`

  Modifications done on php-src docs files.

* `phpdbg-local-console.patch`

  See https://github.com/php/php-src/pull/13199

* `typedef-warnings.patch`

  This fixes many warnings in the build to make the build experience friendlier
  due to various compilation flags used in some cases. It was decided to not
  port upstream but is kept here until C11 is the standard used in PHP:
  https://github.com/php/php-src/pull/13347

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

* `phpdbg-local-console.patch`

  See https://github.com/php/php-src/pull/13199

* `hash.patch`

  See https://github.com/php/php-src/pull/13210
