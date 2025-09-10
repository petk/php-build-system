<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckBuiltin.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckBuiltin.cmake)

# PHP/CheckBuiltin

This module provides a command to check whether the C compiler supports the
given built-in function `__builtin_*()`.

Load this module in a CMake project with:

```cmake
include(PHP/CheckBuiltin)
```

## Commands

This module provides the following command:

### `php_check_builtin()`

Checks whether the C compiler supports the given built-in function:

```cmake
php_check_builtin(<builtin> <result-var>)
```

#### The arguments are:

* `<builtin>`

  Name of the builtin to be checked.

* `<result-var>`

  Name of an internal cache variable to store the boolean result of the check.

When C compiler is `MSVC`, all builtins are reported as not supported.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_HAVE_BUILTIN_CLZ)
```
