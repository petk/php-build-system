#[=============================================================================[
# PHP/CheckSysMacros

Check for non-standard `major`, `minor` and `makedev`. They can be defined as
macros. On Solaris/illumos they are in `sys/mkdev.h` (macro definition to a libc
implementation) and in `sys/sysmacros.h` (macro definition using binary
operators and bits shifting). On systems with musl and glibc 2.28 or later they
are in the `sys/sysmacros.h`. Before glibc 2.28 they were in `sys/types.h` and
with 2.25 glibc deprecated them in favor of the `sys/sysmacros.h`. On BSD-based
systems and macOS they are still in `sys/types.h`.

This check is similar to the Autoconf's `AC_HEADER_MAJOR` since it is already
widely used.

These functions can be then used in the code like this:

```c
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
#]=============================================================================]

include_guard(GLOBAL)

# Skip in consecutive configuration phases.
if(DEFINED _PHP_HAVE_SYS_MACROS_CHECKED)
  return()
endif()

include(CheckIncludeFile)
include(CheckSymbolExists)

message(CHECK_START "Checking for major, minor and makedev")

check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(sys/mkdev.h HAVE_SYS_MKDEV_H)
check_include_file(sys/sysmacros.h HAVE_SYS_SYSMACROS_H)

block()
  set(headers "")

  if(HAVE_SYS_TYPES_H)
    list(APPEND headers "sys/types.h")
  endif()

  if(HAVE_SYS_MKDEV_H)
    check_symbol_exists(major "sys/mkdev.h" MAJOR_IN_MKDEV)
    list(APPEND headers "sys/mkdev.h")
  elseif(HAVE_SYS_SYSMACROS_H)
    check_symbol_exists(major "sys/sysmacros.h" MAJOR_IN_SYSMACROS)
    list(APPEND headers "sys/sysmacros.h")
  endif()

  check_symbol_exists(makedev "${headers}" HAVE_MAKEDEV)
endblock()

if(HAVE_MAKEDEV)
  message(CHECK_PASS "found")
else()
  message(CHECK_FAIL "not found")
endif()

set(
  _PHP_HAVE_SYS_MACROS_CHECKED
  TRUE
  CACHE INTERNAL
  "Internal marker whether 'major', 'minor' and 'makedev' have been checked."
)
