# PHP/SystemExtensions

See: [SystemExtensions.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/SystemExtensions.cmake)

## Basic usage

```cmake
include(PHP/SystemExtensions)
```

Enable extensions to C or POSIX on systems that by default disable them to
conform to standards or namespace issues.

Logic follows the Autoconf's `AC_USE_SYSTEM_EXTENSIONS` macro:
https://www.gnu.org/software/autoconf/manual/autoconf-2.72/html_node/C-and-Posix-Variants.html
with some simplifications for the obsolete systems.

Obsolete preprocessor macros that are not defined by this module:

* `_MINIX`
* `_POSIX_SOURCE`
* `_POSIX_1_SOURCE`

Conditionally defined preprocessor macros:

* `__EXTENSIONS__`
  Defined on Solaris and illumos-based systems.

* `_XOPEN_SOURCE=500`
  Defined on HP-UX.

Result variables:

* `PHP_SYSTEM_EXTENSIONS`
  String for containing all system extensions definitions for usage in the
  configuration header template.

IMPORTED target:

* `PHP::SystemExtensions`
  Interface library target with all required compile definitions (`-D`).

## Usage:

Include the module:

```cmake
include(PHP/SystemExtensions)
```

Add `@PHP_SYSTEM_EXTENSIONS@` placeholder to configuration header template:

```c
# php_config.h
@PHP_SYSTEM_EXTENSIONS@
```

Link targets that require system extensions:

```cmake
target_link_libraries(<target> ... PHP::SystemExtensions)
```

When some check requires, for example, `_GNU_SOURCE` or some other extensions,
link the `PHP::SystemExtensions` target:

```cmake
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
  check_symbol_exists(<symbol> <headers> HAVE_<symbol>)
cmake_pop_check_state()
```

Compile definitions are not appended to `CMAKE_C_FLAGS` for cleaner build
system: `string(APPEND CMAKE_C_FLAGS " -D<extension>=1 ")`.
