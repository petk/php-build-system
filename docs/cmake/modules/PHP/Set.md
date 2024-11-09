# PHP/Set

See: [Set.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/Set.cmake)

Set a CACHE variable that depends on a set of conditions.

At the time of writing, there are three main ways in CMake to create
non-internal cache variables that can also be customized externally via the `-D`
command-line option, CMake presets, or similar:

* `option()`
* `set(<variable> <value> CACHE <type> <docstring>)`
* `cmake_dependent_option()`

Ideally, these are the recommended methods to set configuration variables.
However, there are cases where a `CACHE` variable of a type other than `BOOL`
depends on specific conditions. Additionally, an edge-case issue with
`cmake_dependent_option()` is that it sets a local variable if the conditions
are not met. Local variables in such cases can be difficult to work with
when using `add_subdirectory()`. In the parent scope, instead of a local
variable with a forced value, the cached variable is still defined as
`INTERNAL`, which can lead to bugs in the build process.

## The `php_set()` function

```cmake
php_set(
  <variable>
  TYPE <type>
  [IF <condition> VALUE <value> [ELSE_VALUE <default>]] | [VALUE <value>]
  DOC <docstring>...
)
```

This function sets a cache `<variable>` of `<type>` to a `<value>`.

* `TYPE` can be `BOOL`, `FILEPATH`, `PATH`, or `STRING`.

* `VALUE` is the default variable value. There are two ways to set the default
  value.

  * When using the `IF <condition>` argument, it sets the variable to `<value>`
    if `<condition>` is met. Otherwise it sets the `<variable>` to `ELSE_VALUE`
    `<default>` and hides it in the GUI if `ELSE_VALUE` is provided. Internally,
    `ELSE_VALUE` will set an `INTERNAL` cache variable if `<condition>` is not
    met. If `ELSE_VALUE` is not provided, the `INTERNAL` cache variable is not
    set (it is undefined).

    `IF` behaves the same as the `<depends>` argument in the
    `cmake_dependent_option()`. This supports both full condition syntax and
    semicolon-separated list of conditions.

  * When using only `VALUE` signature, it sets the cache variable to `<value>`,
    which is equivalent to writing:

    ```cmake
    set(<variable> <value> CACHE <type> <docstring>)
    ```

* `DOC` is a short help text for the variable, visible in GUIs. Multiple strings
  are joined together.

  For example:

  ```cmake
  php_set(
    VAR
    TYPE STRING
    IF [[CMAKE_SYSTEM_NAME STREQUAL "Linux"]]
    VALUE "some value"
    DOC
      "This help text "
      "is joined "
      "together."
  )
  ```

## The `CHOICES` signature

The `CHOICES` signature provides a list of options to choose from:

```cmake
php_set(
  <variable>
  [TYPE STRING]
  CHOICES <string>...
  [CHOICES_OPTIONAL]
  [CHOICES_CASE_SENSITIVE]
  [IF <condition> [VALUE <value>] [ELSE_VALUE <default>]] | [VALUE <value>]
  DOC <docstring>...
)
```

* `CHOICES` is a list of items to choose from in the GUI. Internally, it sets
  the `STRINGS` cache variable property. The default `TYPE` is `STRING`, which
  is optional.

  When using `CHOICES`, the `VALUE` keyword is optional. The default variable
  value is set to the first item in the `CHOICES` list.

  For example:

  ```cmake
  include(PHP/Set)
  php_set(
    VAR
    CHOICES auto on off
    DOC "Variable with default value set to the first list item"
  )
  message(STATUS "VAR=${VAR}")
  ```

  Output:

  ```
  VAR=auto
  ```

* When `CHOICES_OPTIONAL` is given, the variable value will not be required to
  match one of the list items. By default, when using `CHOICES`, the variable
  value must match one of the list items; otherwise, a fatal error is thrown.

  For example:

  ```cmake
  php_set(
    VAR
    CHOICES auto on off
    CHOICES_OPTIONAL
    DOC
      "Variable with optional predefined choices where its value can be also "
      "changed to anything else."
  )
  message(STATUS "VAR=${VAR}")
  ```

  ```sh
  cmake -S <source-dir> -B <build-dir> -D VAR=overridden
  ```

  Output:

  ```
  VAR=overridden
  ```

* When `CHOICES_CASE_SENSITIVE` is given, the variable value will need to match
  the case of item defined in the `CHOICES` list. By default, choices are
  case-insensitive.

  For example:

  ```cmake
  php_set(
    VAR
    CHOICES auto unixODBC iODBC
    DOC "Variable with a case-insensitive list of choices"
  )
  message(STATUS "VAR=${VAR}")
  ```

  ```sh
  cmake -S <source-dir> -B <build-dir> -D VAR=unixodbc
  ```

  Will output `VAR=unixODBC` and not `VAR=unixodbc`.

  With `CHOICES_CASE_SENSITIVE`:

  ```cmake
  php_set(
    VAR
    CHOICES auto unixODBC iODBC
    CHOICES_CASE_SENSITIVE
    DOC "Variable with a case-sensitive list of choices"
  )
  message(STATUS "VAR=${VAR}")
  ```

  A fatal error will be thrown, if `VAR` is set to a case-sensitive value
  (`unixodbc`) that does not match any item in the `CHOICES` list.
