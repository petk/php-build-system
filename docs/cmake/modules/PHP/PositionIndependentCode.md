<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/PositionIndependentCode.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/PositionIndependentCode.cmake)

# PHP/PositionIndependentCode

Wrapper module for CMake's `CheckPIESupported` module and
`CMAKE_POSITION_INDEPENDENT_CODE` variable.

This module checks whether to enable the `POSITION_INDEPENDENT_CODE` target
property for all targets globally. The SHARED and MODULE targets have PIC always
enabled by default regardless of this module.

Position independent code (PIC) and position independent executable (PIE)
compile-time and link-time options are for now unconditionally added globally to
all targets, to be able to build shared apache2handler, embed, and phpdbg SAPI
libraries. This probably could be fine tuned in the future further but it can
exponentially complicate the build system code or the build usability.

## Usage

```cmake
# CMakeLists.txt
include(PHP/PositionIndependentCode)
```
