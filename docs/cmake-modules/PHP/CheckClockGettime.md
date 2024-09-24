# PHP/CheckClockGettime

See: [CheckClockGettime.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckClockGettime.cmake)

Check for `clock_get*time()`.

Cache variables:

* `HAVE_CLOCK_GETTIME`
  Whether clock_gettime() is present.
* `HAVE_CLOCK_GET_TIME`
  Whether clock_get_time() is present.

IMPORTED target:

* `PHP::CheckClockGettimeLibrary`
  If there is additional library to be linked for using `clock_gettime()`.
