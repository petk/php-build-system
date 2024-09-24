# PHP/CheckFnmatch

See: [CheckFnmatch.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckFnmatch.cmake)

Check for a working POSIX `fnmatch()` function.

Some versions of Solaris (2.4), SCO, and the GNU C Library have a broken or
incompatible fnmatch. When cross-compiling we only enable it for Linux systems.
Based on the `AC_FUNC_FNMATCH` Autoconf macro.

TODO: This is obsolescent. See Gnulib's fnmatch-gnu module:
https://www.gnu.org/software/gnulib/MODULES.html#module=fnmatch

Cache variables:

* `HAVE_FNMATCH`
  Whether `fnmatch` is a working POSIX variant.
