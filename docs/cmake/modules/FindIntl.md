# FindIntl

See: [FindIntl.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindIntl.cmake)

## Basic usage

```cmake
include(cmake/FindIntl.cmake)
```

Find the Intl library.

Module overrides the upstream CMake `FindIntl` module with few customizations.

Enables finding Intl library with `Intl_ROOT` hint variable.

See: https://cmake.org/cmake/help/latest/module/FindIntl.html

Hints:

The `Intl_ROOT` variable adds custom search path.
