<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckAttribute.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckAttribute.cmake)

# PHP/CheckAttribute

This module provides command to check if GNU C function or variable attribute is
supported by the C compiler.

Load this module in a CMake project with:

```cmake
include(PHP/CheckAttribute)
```

## Commands

This module provides the following commands:

### `php_check_function_attribute()`

Checks whether the GNU C function attribute is supported by the C compiler:

```cmake
php_check_function_attribute(<attribute> <result-var>)
```

#### The arguments are:

* `<attribute>`

  Name of the function attribute to check.

  Supported function attributes:

  * `ifunc`
  * `target`
  * `visibility`

* `<result-var>`

  Name of an internal cache variable to store the result of whether the C
  compiler supports the function attribute `<attribute>`.

### `php_check_variable_attribute()`

Checks whether the GNU C variable attribute is supported by the C compiler:

```cmake
php_check_variable_attribute(<attribute> <result-var>)
```

#### The arguments are:

* `<attribute>`

  Name of the variable attribute to check.

  Supported variable attributes:

  * `aligned`

* `<result-var>`

  Name of an internal cache variable to store the result of whether the C
  compiler supports the variable attribute `<attribute>`.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

include(PHP/CheckAttribute)

php_check_function_attribute(ifunc PHP_HAVE_FUNC_ATTRIBUTE_IFUNC)
php_check_variable_attribute(aligned PHP_HAVE_VAR_ATTRIBUTE_ALIGNED)
```
