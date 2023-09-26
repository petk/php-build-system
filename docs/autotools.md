# Autotools

This is a brief introduction to Autotools build system.

* [1. Determining platform](#1-determining-platform)
* [2. Testing if program works](#2-testing-if-program-works)
  * [2.1. AC\_COMPILE\_IFELSE](#21-ac_compile_ifelse)
  * [2.2. AC\_LINK\_IFELSE](#22-ac_link_ifelse)
  * [2.3. AC\_RUN\_IFELSE](#23-ac_run_ifelse)
* [3. GNU Autoconf Archive](#3-gnu-autoconf-archive)
* [4. See more](#4-see-more)

## 1. Determining platform

With Autotools there are several shell variables that help determine the
platform characteristics such as CPU, operating system and vendor name. When
using macros `AC_CANONICAL_BUILD`, `AC_CANONICAL_HOST`, and
`AC_CANONICAL_TARGET` in the M4 files, `config.sub` and `config.sub` scripts
help determine the values of variables `build_alias`, `host_alias`, and
`target_alias`.

Users can also manually override these variables for their specific case using
the `--build`, `--host`, and `--target` configure options.

In M4 files platform can be then determined using above shell variables in
variety of ways:

```m4
AS_CASE([$host_alias],[*freebsd*|*openbsd*],[
  # Action that is run only on FreeBSD and OpenBSD systems.
])
```

## 2. Testing if program works

There are 3 main Autoconf macros that check if certain test code is successful.

Let's check a simple C program:

```c
#include <stdio.h>

int main(void) {
    printf("Hello World");

    return 0;
}
```

### 2.1. AC_COMPILE_IFELSE

```m4
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <stdio.h>]],
  [[printf("Hello World")]])],
  [php_cv_func_printf_works=yes],
  [php_cv_func_printf_works=no])
```

The `AC_LANG_PROGRAM` macro will expand this into:

```c
#include <stdio.h>

int main(void) {
  printf("Hello World")
  ;
  return 0;
}
```

The `AC_COMPILE_IFELSE` will run the compilation step, for example:

```sh
gcc -o out -c hello_world.c
```

### 2.2. AC_LINK_IFELSE

```m4
AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <stdio.h>]],
  [[printf("Hello World")]])],
  [php_cv_func_printf_works=yes],
  [php_cv_func_printf_works=no])
```

This will run compilation and linking:

```sh
gcc -o out hello_world.c
```

### 2.3. AC_RUN_IFELSE

This will compile, link and also run the program to check if the return code is
0.

Issue with `AC_RUN_IFELSE` is when doing so called cross-compilation. That is
bulding C software on one platform with purpose of running it on some other
platform. In this case the program cannot be run and we cannot be sure of if it
is running successfully or not.

```m4
AC_RUN_IFELSE([AC_LANG_PROGRAM([[#include <stdio.h>]],
  [[printf("Hello World")]])],
  [php_cv_func_printf_works=yes],
  [php_cv_func_printf_works=no],
  [php_cv_func_printf_works=cross-compiling])
```

This does something like this:

```sh
gcc -o out hello_world.c
./out
```

## 3. GNU Autoconf Archive

To reuse the code there is a community collection of Autoconf macros available
at [autoconf-archive](https://github.com/autoconf-archive/autoconf-archive).

PHP is not using Automake so it includes them like this in `configure.ac`:

```m4
m4_include([build/ax_..._.m4])
m4_include([build/...macro.m4])
# ...
```

They can be than called and expanded in the m4 code:

```m4
AX_MACRO_CALL(...)
```

When using Automake, these can be automatically included like this:

```m4
AC_CONFIG_MACRO_DIR([path/to/m4/dir])
```

However, the `aclocal` from Automake is needed for this to work.

## 4. See more

Useful resources to learn more about Autoconf and Autotools in general:

* [Autoconf documentation](https://www.gnu.org/software/autoconf/manual/index.html)
* [Autotools Mythbuster](https://autotools.info/) - guide to Autotools
