<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/SystemExtensions.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/SystemExtensions.cmake)

# PHP/SystemExtensions

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

## Result variables

* `PHP_SYSTEM_EXTENSIONS_CODE`

  The configuration header code containing all system extensions definitions.

## IMPORTED target

* `PHP::SystemExtensions`

  Interface library target with all required compile definitions (`-D`).

## Basic usage

Targets that require some system extensions can link to `PHP::SystemExtensions`:

```cmake
# CMakeLists.txt
include(PHP/SystemExtensions)
target_link_libraries(<target> PHP::SystemExtensions)
```

When some check requires, for example, `_GNU_SOURCE` or some other extensions,
link the `PHP::SystemExtensions` target:

```cmake
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
  check_symbol_exists(<symbol> <headers> HAVE_<symbol>)
cmake_pop_check_state()
```

## Configuration header code

To configure header file, add a placeholder to template, for example:

```c
# config.h.in
@PHP_SYSTEM_EXTENSIONS_CODE@
```

And include module:

```cmake
# CMakeLists.txt
include(PHP/SystemExtensions)
configure_file(config.h.in config.h)
```

## Notes

Compile definitions are not appended to `CMAKE_C_FLAGS` for cleaner build
system. For example, this is not done by this module:

```cmake
string(APPEND CMAKE_C_FLAGS " -D<extension>=1 ")`
```