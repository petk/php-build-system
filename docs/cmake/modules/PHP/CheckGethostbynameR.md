<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckGethostbynameR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckGethostbynameR.cmake)

# PHP/CheckGethostbynameR

Check `gethostbyname_r()`.

The non-standard `gethostbyname_r()` function has different signatures across
systems:

* Linux, BSD: 6 arguments
* Solaris, illumos: 5 arguments
* AIX, HP-UX: 3 arguments
* Haiku: network library has it for internal purposes, not intended for usage
  from the system headers.

See also:
https://www.gnu.org/software/autoconf-archive/ax_func_which_gethostbyname_r.html

## Cache variables

* `HAVE_FUNC_GETHOSTBYNAME_R_6`

  Whether `gethostbyname_r()` has 6 arguments.

* `HAVE_FUNC_GETHOSTBYNAME_R_5`

  Whether `gethostbyname_r()` has 5 arguments.

* `HAVE_FUNC_GETHOSTBYNAME_R_3`

  Whether `gethostbyname_r()` has 3 arguments.

## Result variables

* `HAVE_GETHOSTBYNAME_R`

  Whether `gethostbyname_r()` is available.

## INTERFACE library

* `PHP::CheckGethostbynameR`

  Created when additional system library needs to be linked.

## Usage

```cmake
# CMakeLists.txt
include(PHP/CheckGethostbynameR)
```
