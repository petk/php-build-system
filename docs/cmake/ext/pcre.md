<!-- This is auto-generated file. -->
* Source code: [ext/pcre/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/pcre/CMakeLists.txt)

# The pcre extension

Configure the `pcre` extension.

This extension provides support for (Perl-compatible) regular expressions and is
always enabled.

## EXT_PCRE_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Use external (system) PCRE library in pcre extension instead of the bundled PCRE
library that comes with PHP sources.

## EXT_PCRE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enable PCRE JIT (just-in-time) compilation. When using the external PCRE
library, JIT support also depends on the target processor architecture and
whether the PCRE library has it enabled.
