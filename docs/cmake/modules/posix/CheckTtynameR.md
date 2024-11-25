<!-- This is auto-generated file. -->
* Source code: [ext/posix/cmake/CheckTtynameR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/ext/posix/cmake/CheckTtynameR.cmake)

# CheckTtynameR

Check `ttyname_r()`.

On Solaris/illumos `ttyname_r()` works only with larger buffers (>= 128),
unlike, for example, on Linux and other systems, where buffer size can be any
`size_t` size, also < 128. PHP code uses `ttyname_r()` with large buffers, so it
wouldn't be necessary to check small buffers but the run check below is kept for
brevity.

On modern systems a simpler check is sufficient in the future:

```cmake
check_symbol_exists(ttyname_r unistd.h HAVE_TTYNAME_R)
```

## Cache variables

* `HAVE_TTYNAME_R`

  Whether `ttyname_r()` works as expected.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckTtynameR.cmake)
```
