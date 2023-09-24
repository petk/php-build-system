# Autotools

This is a brief introduction to Autotools build system.

* [1. Testing if program works](#1-testing-if-program-works)
  * [1.1. AC\_COMPILE\_IFELSE](#11-ac_compile_ifelse)
  * [1.2. AC\_LINK\_IFELSE](#12-ac_link_ifelse)
  * [1.3. AC\_RUN\_IFELSE](#13-ac_run_ifelse)
* [2. GNU Autoconf Archive](#2-gnu-autoconf-archive)
* [3. See more](#3-see-more)

## 1. Testing if program works

There are 3 main Autoconf macros that check if certain test code is successful.

Let's check a simple C program:

```c
#include <stdio.h>

int main(void) {
    printf("Hello World");

    return 0;
}
```

### 1.1. AC_COMPILE_IFELSE

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

### 1.2. AC_LINK_IFELSE

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

### 1.3. AC_RUN_IFELSE

This will compile, link and also run the program and check if the return code is
0.

Issue with `AC_RUN_IFELSE` is when doing so called cross-compilation. That is
bulding C software on one platform with purpose of running it on some other
platform. In this case the program cannot be run and we cannot be sure of if it
running successfully or not.

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

## 2. GNU Autoconf Archive

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

## 3. See more

Useful resources to learn more about Autoconf and Autotools in general:

* [Autoconf documentation](https://www.gnu.org/software/autoconf/manual/index.html)
* [Autotools Mythbuster](https://autotools.info/) - guide to Autotools
