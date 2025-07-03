<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckAttribute.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckAttribute.cmake)

# PHP/CheckAttribute

This module checks if GNU C function or variable attribute is supported by the
C compiler:

```cmake
include(PHP/CheckAttribute)
```

## Commands

This module provides the following commands:

```cmake
php_check_function_attribute(<attribute> <result-var>)
php_check_variable_attribute(<attribute> <result-var>)
```

* `<attribute>`
  Name of the attribute to check.

* `<result-var>`
  Cache variable name to store the result of whether the C compiler supports the
  attribute `<attribute>`.

Supported function attributes:

* ifunc
* target
* visibility

Supported variable attributes:

* aligned

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/CheckAttribute)

php_check_function_attribute(ifunc HAVE_FUNC_ATTRIBUTE_IFUNC)
php_check_variable_attribute(aligned HAVE_ATTRIBUTE_ALIGNED)
```
