<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/VerboseLink.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/VerboseLink.cmake)

# PHP/VerboseLink

This module checks whether to enable verbose output by linker:

```cmake
include(PHP/VerboseLink)
```

This module provides the `PHP_VERBOSE_LINK` option to control enabling the
verbose link output. Verbose linker flag is added to the global `php_config`
target.

## Examples

When configuring project, enable the `PHP_VERBOSE_LINK` option to get verbose
output at the link step:

```sh
cmake -B php-build -D PHP_VERBOSE_LINK=ON
cmake --build php-build -j
```
