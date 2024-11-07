# FindPHP

See: [FindPHP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/ext/skeleton/cmake/modules/FindPHP.cmake)

Find PHP.

Components:

* `php` - The PHP, general-purpose scripting language, component for building
  extensions.
* `embed` - The PHP Embed SAPI component - A lightweight SAPI to embed PHP into
  application using C bindings.

Module defines the following `IMPORTED` target(s):

* `PHP::php` - The PHP package `IMPORTED` target, if found.
* `PHP:embed` - The PHP embed SAPI, if found.

Result variables:

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

Cache variables:

* `PHP_CONFIG_EXECUTABLE` - Path to the php-config development helper tool.
* `PHP_INCLUDE_DIR` - Directory containing PHP headers.
* `PHP_EMBED_LIBRARY` - The path to the PHP Embed library.
* `PHP_EMBED_INCLUDE_DIR` - Directory containing PHP Embed header(s).

Hints:

The `PHP_ROOT` variable adds custom search path.

Examples:

```cmake
# Find PHP
find_package(PHP)

# Find PHP embed component
find_package(PHP COMPONENTS embed)

# Override where to find PHP
set(PHP_ROOT /path/to/php/installation)
find_package(PHP)
```