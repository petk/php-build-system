<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckSysMacros.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckSysMacros.cmake)

# PHP/CheckSysMacros

This module checks for non-standard C functions `major()`, `minor()` and
`makedev()`.

Load this module in a CMake project with:

```cmake
include(PHP/CheckSysMacros)
```

These C functions can be defined on some systems as macros. On Solaris/illumos
they are in `<sys/mkdev.h>` (macro definitions to a libc implementation) and in
`<sys/sysmacros.h>` (macro definitions using binary operators and bits
shifting). On systems with musl and glibc 2.28 or later they are in the
`<sys/sysmacros.h>`. Before glibc 2.28 they were in `<sys/types.h>` and glibc
2.25 version has deprecated them in favor of the `<sys/sysmacros.h>`. On
BSD-based systems and macOS they are still in `<sys/types.h>`.

This check is similar to the Autoconf's `AC_HEADER_MAJOR` since it is already
used out there.

## Result variables

Including this module defines the following regular variables:

* `HAVE_SYS_TYPES_H`

  Defined to 1 if the `<sys/types.h>` header file is available.

* `HAVE_SYS_MKDEV_H`

  Defined to 1 if the `<sys/mkdev.h>` header file is available.

* `HAVE_SYS_SYSMACROS_H`

  Defined to 1 if the `<sys/sysmacros.h>` header file is available.

* `MAJOR_IN_MKDEV`

  Defined to 1 if `major`, `minor`, and `makedev` are declared in
  `<sys/mkdev.h>`.

* `MAJOR_IN_SYSMACROS`

  Defined to 1 if `major`, `minor`, and `makedev` are declared in
  `<sysmacros.h>`.

* `HAVE_MAKEDEV`

  Defined to 1 if the `makedev` function is available.

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
