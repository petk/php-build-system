<!-- This is auto-generated file. -->
* Source code: [Zend/cmake/CheckGlobalRegisterVariables.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/CheckGlobalRegisterVariables.cmake)

# CheckGlobalRegisterVariables

Check whether the compiler and target system support global register variables.

Global register variables are relevant for the GNU C compatible compilers.

See also: [GCC global register variables](https://gcc.gnu.org/onlinedocs/gcc/Global-Register-Variables.html)

## Cache variables

* `HAVE_GCC_GLOBAL_REGS`

  Whether global register variables are supported.

## Usage

```cmake
# CMakeLists.txt
include(cmake/CheckGlobalRegisterVariables.cmake)
```
