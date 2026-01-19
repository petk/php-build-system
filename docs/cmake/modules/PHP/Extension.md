<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/Extension.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Extension.cmake)

# PHP/Extension

This module provides commands to configure PHP extensions.

Load this module in a PHP extension's project with:

```cmake
include(PHP/Extension)
```

## Commands

### `php_extension()`

Configures PHP extension:

```cmake
php_extension(<php-extension-name>)
```

The arguments are:

* `<php-extension-name>` - lowercase name of the PHP extension being configured.

This command adjusts configuration in the current directory for building PHP
extension and prepares its target for using it with PHP.

## Examples

Configuring PHP extension:

```cmake
# ext/foo/CMakeLists.txt

include(PHP/Extension)
php_extension(foo)
```
