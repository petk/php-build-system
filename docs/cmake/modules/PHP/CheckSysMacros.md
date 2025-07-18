<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckSysMacros.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckSysMacros.cmake)

# PHP/CheckSysMacros

This module checks for non-standard `major()`, `minor()` and `makedev()`:

```cmake
include(PHP/CheckSysMacros)
```

These functions can be defined on some systems as macros. On Solaris/illumos
they are in `<sys/mkdev.h>` (macro definitions to a libc implementation) and in
`<sys/sysmacros.h>` (macro definitions using binary operators and bits
shifting). On systems with musl and glibc 2.28 or later they are in the
`<sys/sysmacros.h>`. Before glibc 2.28 they were in `<sys/types.h>` and
glibc 2.25 version has deprecated them in favor of the `<sys/sysmacros.h>`. On
BSD-based systems and macOS they are still in `<sys/types.h>`.

This check is similar to the Autoconf's `AC_HEADER_MAJOR` since it is already
used out there.

## Cache variables

* `HAVE_SYS_TYPES_H`

  Define to 1 if you have the `<sys/types.h>` header file.

* `HAVE_SYS_MKDEV_H`

  Define to 1 if you have the `<sys/mkdev.h>` header file.

* `HAVE_SYS_SYSMACROS_H`

  Define to 1 if you have the `<sys/sysmacros.h>` header file.

* `MAJOR_IN_MKDEV`

  Define to 1 if `major`, `minor`, and `makedev` are declared in
  `<sys/mkdev.h>`.

* `MAJOR_IN_SYSMACROS`

  Define to 1 if `major`, `minor`, and `makedev` are declared in
  `<sysmacros.h>`.

* `HAVE_MAKEDEV`

  Define to 1 if you have the `makedev` function.

## Examples

Including this module will define the result variables that can be used
in the configuration header:

```cmake
# CMakeLists.txt
include(PHP/CheckSysMacros)
configure_file(config.h.in config.h)
```

These functions can be then used in the code like this:

```c
#include <config.h>

#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef MAJOR_IN_MKDEV
# include <sys/mkdev.h>
#elif defined(MAJOR_IN_SYSMACROS)
# include <sys/sysmacros.h>
#endif
int main(void)
{
  /* ... */
  #ifdef HAVE_MAKEDEV
  device = makedev(major, minor);
  #endif
  /* ... */
}
```
