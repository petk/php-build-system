<!-- This is auto-generated file. -->
* Source code: [ext/opcache/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/opcache/CMakeLists.txt)

# The Zend OPcache extension

This extension enables the PHP OPcode caching engine.

## PHP_EXT_OPCACHE

:red_circle: *Removed as of PHP 8.5.*

* Default: `ON`
* Values: `ON|OFF`

Enable the extension. This extension is always built as shared when enabled. As
of PHP 8.5, this extension is always enabled and cannot be disabled.

## PHP_EXT_OPCACHE_HUGE_CODE_PAGES

* Default: `ON`
* Values: `ON|OFF`

Enable copying PHP CODE pages into HUGE PAGES.

> [!NOTE]
> This option is not available when the target system is Windows.

## PHP_EXT_OPCACHE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enable JIT (just-in-time) compilation.

## PHP_EXT_OPCACHE_CAPSTONE

* Default: `OFF`
* Values: `ON|OFF`

Enable OPcache JIT disassembly through Capstone engine.
