# PHP/Set

See: [Set.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/Set.cmake)

Set a CACHE variable that depends on a set of conditions.

At the time of writing, there are 3 main ways in CMake to create non-internal
cache variables that can be also customized from the outside using the `-D`
command-line option, through CMake presets, or similar:
* `option()`
* `set(<variable> <value> CACHE <type> <docstring>)`
* `cmake_dependent_option()`

Ideally, these are the recommended ways to set configuration variables. However,
there are many cases where a `CACHE` variable of a type other than `BOOL`
depends on certain conditions. Additionally, an edge-case issue with
`cmake_dependent_option()` is that it sets a local variable if the conditions
are not met. Local variables in such edge cases can be difficult to work with
when using `add_subdirectory()`. In the parent scope, instead of the local
variable with a forced value, the cached variable is still defined as
`INTERNAL`, which can lead to bugs in the build process.

This module exposes the following function:

```cmake
php_set(
  <variable>
  TYPE <type>
  [CHOICES <string>...]
  [IF <condition> VALUE <value> [ELSE_VALUE <default>]] | [VALUE <value>]
  DOC <docstring>...
)
```

It sets a CACHE `<variable>` of `<type>` to a `<value>`.

* `TYPE` can be `BOOL`, `FILEPATH`, `PATH`, or `STRING`.

* `CHOICES` is an optional list of items when `STRING` type is used to create
  a list of supported options to pick in the GUI. Under the hood, it sets the
  `STRINGS` CACHE variable property.

* `VALUE` is the default variable value. There are two ways to set default
  value.

  * When using the `IF <condition>` argument, it sets the variable to `<value>`
    if `<condition>` is met. Otherwise it sets the `<variable>` to `ELSE_VALUE`
    `<default>` and hides it in the GUI, if `ELSE_VALUE` is given. Under the
    hood `ELSE_VALUE` will set `INTERNAL` cache variable if `<condition>` is not
    met. If `ELSE_VALUE` is not provided, the `INTERNAL` cache variable is not
    set (it is undefined).

    `IF` behaves the same as the `<depends>` argument in the
    `cmake_dependent_option()`. This supports both full condition syntax and
    semicolon-separated list of conditions.

  * When using only `VALUE` signature, it sets the cache variable to `<value>`.
    It is the same as writing:

    ```cmake
    set(<variable> <value> CACHE <type> <docstring>)
    ```

* `DOC` is a short variable help text visible in the GUIs. Multiple strings are
  joined together.
