<!-- This is auto-generated file. -->
# PHP/CheckGetaddrinfo

* Module source code: [CheckGetaddrinfo.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckGetaddrinfo.cmake)

Check for working `getaddrinfo()`.

Cache variables:

* `HAVE_GETADDRINFO`
  Whether `getaddrinfo()` function is working as expected.

IMPORTED target:

* `PHP::CheckGetaddrinfoLibrary`
  If there is additional library to be linked for using `getaddrinfo()`.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckGetaddrinfo)
```
