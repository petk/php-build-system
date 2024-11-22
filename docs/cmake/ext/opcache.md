<!-- This is auto-generated file. -->
* Source code: [ext/opcache/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/opcache/CMakeLists.txt)

# The Zend OPcache extension

This extension enables the PHP OPcode caching engine.

## EXT_OPCACHE

* Default: `ON`
* Values: `ON|OFF`

Enable the extension. This extension is always built as shared when enabled.

## EXT_OPCACHE_HUGE_CODE_PAGES

* Default: `ON`
* Values: `ON|OFF`

Enable copying PHP CODE pages into HUGE PAGES.

## EXT_OPCACHE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enable JIT (Just-In-Time compiler).

## EXT_OPCACHE_CAPSTONE

* Default: `OFF`
* Values: `ON|OFF`

Enable OPcache JIT disassembly through Capstone engine.
