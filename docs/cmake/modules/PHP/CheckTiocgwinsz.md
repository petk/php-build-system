# PHP/CheckTiocgwinsz

See: [CheckTiocgwinsz.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckTiocgwinsz.cmake)

Check if any of the expected headers define `TIOCGWINSZ`.

Some systems define `TIOCGWINSZ` (Terminal Input Output Control Get WINdow SiZe)
to obtain the number of rows and columns in the terminal window. This is based
on Autoconf's `AC_HEADER_TIOCGWINSZ` macro approach.

Cache variables:

* `GWINSZ_IN_SYS_IOCTL`
  Whether `sys/ioctl.h` defines `TIOCGWINSZ`.