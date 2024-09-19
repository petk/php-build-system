# PHP/CheckStrerrorR

Check for `strerror_r()`, and if its a POSIX-compatible or a GNU-specific
version.

Cache variables:

* `HAVE_STRERROR_R`
  Whether `strerror_r()` is available.
* `STRERROR_R_CHAR_P`
  Whether `strerror_r()` returns a `char *` message, otherwise it returns an
  `int` error number.
