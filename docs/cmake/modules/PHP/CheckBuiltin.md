<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckBuiltin.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckBuiltin.cmake)

# PHP/CheckBuiltin

This module checks whether the C compiler supports one of the built-in functions
`__builtin_*()`:

```cmake
include(PHP/CheckBuiltin)
```

## Commands

This module provides the following command:

```cmake
php_check_builtin(<builtin> <result-var>)
```

If builtin `<builtin>` is supported by the C compiler, store the check result in
the cache variable `<result-var>`.

When C compiler is `MSVC`, all builtins are reported as not supported.

## Examples

```cmake
# CMakeLists.txt
include(PHP/CheckBuiltin)
php_check_builtin(__builtin_clz PHP_HAVE_BUILTIN_CLZ)
```
