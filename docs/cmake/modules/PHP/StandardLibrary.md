<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/StandardLibrary.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/StandardLibrary.cmake)

# PHP/StandardLibrary

This module determines the C standard library used for the build.

Load this module in a CMake project with:

```cmake
include(PHP/StandardLibrary)
```

## Variables

Including this module will define the following variables:

### Cache variables

* `PHP_C_STANDARD_LIBRARY`

  Lowercase name of the C standard library. This internal cache variable will be
  set to one of the following values:

    * `cosmopolitan`
    * `dietlibc`
    * `glibc`
    * `llvm`
    * `mscrt`
    * `musl`
    * `picolibc`
    * `uclibc`
    * "" (empty string)

      If C standard library cannot be determined, it is set to empty string.

### Result variables:

* `PHP_C_STANDARD_LIBRARY_CODE`

  CMake variable containing some helper code for use in the C configuration
  header.

  For example, when C standard library implementation is musl, the value of this
  variable will contain:

  ```c
  /* Define to 1 when using musl libc. */
  #define __MUSL__ 1
  ```

## Examples

Basic usage:

```cmake
# CMakeLists.txt

include(PHP/StandardLibrary)

message(STATUS "PHP_C_STANDARD_LIBRARY=${PHP_C_STANDARD_LIBRARY}")

file(CONFIGURE OUTPUT config.h CONTENT [[
@PHP_C_STANDARD_LIBRARY_CODE@
]])
```
