# PHP/CheckGetaddrinfo

See: [CheckGetaddrinfo.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckGetaddrinfo.cmake)

Check for working `getaddrinfo()`.

Cache variables:

* `HAVE_GETADDRINFO`
  Whether `getaddrinfo()` function is working as expected.

IMPORTED target:

* `PHP::CheckGetaddrinfoLibrary`
  If there is additional library to be linked for using `getaddrinfo()`.
