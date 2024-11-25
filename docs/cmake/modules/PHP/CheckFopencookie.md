<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckFopencookie.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckFopencookie.cmake)

# PHP/CheckFopencookie

Check if `fopencookie()` works as expected.

Module first checks if `fopencookie()` and type `cookie_io_functions_t` are
available. Then it checks whether the fopencookie seeker uses type `off64_t`.
Since `off64_t` is non-standard and obsolescent, the standard `off_t` type can
be used on both 64-bit and 32-bit systems, where the `_FILE_OFFSET_BITS=64` can
make it behave like `off64_t` on 32-bit. Since code is in the transition process
to use `off_t` only, check is left here when using glibc.

## Cache variables

* `HAVE_FOPENCOOKIE`

  Whether `fopencookie()` and `cookie_io_functions_t` are available.

* `COOKIE_SEEKER_USES_OFF64_T`

  Whether `fopencookie` seeker uses the `off64_t` type.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckFopencookie)
```
