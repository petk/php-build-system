<!-- This is auto-generated file. -->
# PHP/CheckBuiltin

* Module source code: [CheckBuiltin.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckBuiltin.cmake)

Check whether compiler supports one of the built-in functions `__builtin_*()`.

Module exposes the following function:

```cmake
php_check_builtin(<builtin> <result_var>)
```

If builtin `<builtin>` is supported by the C compiler, store the check result in
the cache variable `<result_var>`.

For example:

```cmake
include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_HAVE_BUILTIN_CLZ)
```

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/CheckBuiltin)
```
