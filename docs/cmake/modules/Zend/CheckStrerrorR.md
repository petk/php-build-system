<!-- This is auto-generated file. -->
* Source code: [Zend/cmake/CheckStrerrorR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/CheckStrerrorR.cmake)

# CheckStrerrorR

Check whether `strerror_r()` is the POSIX-compatible version or the GNU-specific
version.

## Cache variables

* `HAVE_STRERROR_R`

  Whether `strerror_r()` is available.

* `STRERROR_R_CHAR_P`

  Whether `strerror_r()` returns a `char *` message, otherwise it returns an
  `int` error number.

## Usage

```cmake
# CMakeLists.txt
include(cmake/CheckStrerrorR.cmake)
```
