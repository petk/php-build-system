<!-- This is auto-generated file. -->
* Source code: [ext/pcre/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/pcre/CMakeLists.txt)

# The pcre extension

This extension provides support for (Perl-compatible) regular expressions and is
always enabled.

## Configuration options

### PHP_EXT_PCRE_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Uses external (system) PCRE library in pcre extension instead of the bundled
PCRE library that comes with PHP sources.

### PHP_EXT_PCRE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enables PCRE JIT (just-in-time) compilation. When using the external PCRE
library, JIT support also depends on the target processor architecture and
whether the PCRE library has it enabled.
