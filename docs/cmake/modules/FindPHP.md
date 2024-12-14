<!-- This is auto-generated file. -->
* Source code: [ext/skeleton/cmake/modules/FindPHP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/ext/skeleton/cmake/modules/FindPHP.cmake)

# FindPHP

Find PHP.

Components:

* `php` - The PHP, general-purpose scripting language, component for building
  extensions.
* `embed` - The PHP Embed SAPI component - A lightweight SAPI to embed PHP into
  application using C bindings.

Module defines the following `IMPORTED` target(s):

* `PHP::php` - The PHP package `IMPORTED` target, if found.
* `PHP::embed` - The PHP embed SAPI, if found.

## Result variables

* `PHP_FOUND` - Whether the package has been found.
* `PHP_INCLUDE_DIRS` - Include directories needed to use this package.
* `PHP_LIBRARIES` - Libraries needed to link to the package library.
* `PHP_VERSION` - Package version, if found.
* `PHP_INSTALL_INCLUDEDIR` - Relative path to the `CMAKE_PREFIX_INSTALL`
  containing PHP headers.
* `PHP_EXTENSION_DIR` - Path to the directory where shared extensions are
  installed.
* `PHP_API_VERSION` - Internal PHP API version number (`PHP_API_VERSION` in
  `<main/php.h>`).
* `PHP_ZEND_MODULE_API` - Internal API version number for PHP extensions
  (`ZEND_MODULE_API_NO` in `<Zend/zend_modules.h>`). These are most common PHP
  extensions either built-in or loaded dynamically with the `extension` INI
  directive.
* `PHP_ZEND_EXTENSION_API` - Internal API version number for Zend extensions
  (`ZEND_EXTENSION_API_NO` in `<Zend/zend_extensions.h>`). Zend extensions are,
  for example, opcache, debuggers, profilers and similar advanced extensions.
  They are either built-in or dynamically loaded with the `zend_extension` INI
  directive.

## Cache variables

* `PHP_CONFIG_EXECUTABLE` - Path to the php-config development helper tool.
* `PHP_INCLUDE_DIR` - Directory containing PHP headers.
* `PHP_EMBED_LIBRARY` - The path to the PHP Embed library.
* `PHP_EMBED_INCLUDE_DIR` - Directory containing PHP Embed header(s).

Basic usage:

```cmake
# Find PHP
find_package(PHP)

# Find PHP embed component
find_package(PHP COMPONENTS embed)

# Override where to find PHP
set(PHP_ROOT /path/to/php/installation)
find_package(PHP)
```

## Basic usage

```cmake
# CMakeLists.txt
find_package(PHP)
```

## Customizing search locations

To customize where to look for the PHP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `PHP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/PHP;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DPHP_ROOT=/opt/PHP \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
