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

## Examples

Configuring pcre extension with external PCRE library:

```sh
cmake -B <build-dir> -DPHP_EXT_PCRE_EXTERNAL=ON
```

When using external PCRE library, finding PCRE library installation can be
configured by setting the `CMAKE_PREFIX_PATH` variable or by setting the
individual `<PackageName>_ROOT` variable.

For example, to specify custom installation of PCRE library:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_PCRE_EXTERNAL=ON \
  -DCMAKE_PREFIX_PATH="/path/to/pcre2-installation"
```

Or:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_PCRE_EXTERNAL=ON \
  -DPCRE2_ROOT="/path/to/pcre2-installation"
```

External static PCRE library can be found with:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_PCRE_EXTERNAL=ON \
  -DCMAKE_PREFIX_PATH="/path/to/pcre2-installation" \
  -DPCRE2_USE_STATIC_LIBS=ON
```
