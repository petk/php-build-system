#[=============================================================================[
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

## Result variables

This module defines the following regular variables:

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
#]=============================================================================]

foreach(
  var IN ITEMS
    HAVE_SYS_TYPES_H
    HAVE_SYS_MKDEV_H
    HAVE_SYS_SYSMACROS_H
    MAJOR_IN_MKDEV
    MAJOR_IN_SYSMACROS
    HAVE_MAKEDEV
)
  set(${var} FALSE)

  if(DEFINED PHP_${var})
    set(${var} ${PHP_${var}})
  endif()
endforeach()

include_guard(GLOBAL)

# Skip in consecutive configuration phases or when targeting Windows.
if(PHP_HAS_SYS_MACROS_CHECKED OR CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFiles)
include(CheckSymbolExists)

message(CHECK_START "Checking for major, minor and makedev")

check_include_files(sys/types.h PHP_HAVE_SYS_TYPES_H)
set(HAVE_SYS_TYPES_H ${PHP_HAVE_SYS_TYPES_H})

check_include_files(sys/mkdev.h PHP_HAVE_SYS_MKDEV_H)
set(HAVE_SYS_MKDEV_H ${PHP_HAVE_SYS_MKDEV_H})

check_include_files(sys/sysmacros.h PHP_HAVE_SYS_SYSMACROS_H)
set(HAVE_SYS_SYSMACROS_H ${PHP_HAVE_SYS_SYSMACROS_H})

block(PROPAGATE MAJOR_IN_MKDEV MAJOR_IN_SYSMACROS HAVE_MAKEDEV)
  set(headers "")

  if(PHP_HAVE_SYS_TYPES_H)
    list(APPEND headers "sys/types.h")
  endif()

  if(PHP_HAVE_SYS_MKDEV_H)
    check_symbol_exists(major sys/mkdev.h PHP_MAJOR_IN_MKDEV)
    set(MAJOR_IN_MKDEV ${PHP_MAJOR_IN_MKDEV})
    list(APPEND headers "sys/mkdev.h")
  elseif(PHP_HAVE_SYS_SYSMACROS_H)
    check_symbol_exists(major sys/sysmacros.h PHP_MAJOR_IN_SYSMACROS)
    set(MAJOR_IN_SYSMACROS ${PHP_MAJOR_IN_SYSMACROS})
    list(APPEND headers "sys/sysmacros.h")
  endif()

  check_symbol_exists(makedev "${headers}" PHP_HAVE_MAKEDEV)
  set(HAVE_MAKEDEV ${PHP_HAVE_MAKEDEV})
endblock()

if(PHP_HAVE_MAKEDEV)
  message(CHECK_PASS "found")
else()
  message(CHECK_FAIL "not found")
endif()

set(
  PHP_HAS_SYS_MACROS_CHECKED
  TRUE
  CACHE INTERNAL
  "Internal marker whether 'major', 'minor' and 'makedev' have been checked."
)
