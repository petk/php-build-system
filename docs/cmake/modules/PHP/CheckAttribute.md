<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/CheckAttribute.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/CheckAttribute.cmake)

# PHP/CheckAttribute

Check if GNU C function or variable attribute is supported by the compiler.

Module exposes the following functions:

```cmake
php_check_function_attribute(<attribute> <result>)
php_check_variable_attribute(<attribute> <result>)
```

* `<attribute>`
  Name of the attribute to check.

* `<result>`
  Cache variable name to store the result of whether the compiler supports the
  attribute `<attribute>`.

Supported function attributes:

* ifunc
* target
* visibility

Supported variable attributes:

* aligned

## Usage

```cmake
# CMakeLists.txt
include(PHP/CheckAttribute)
```
