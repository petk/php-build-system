<!-- This is auto-generated file. -->
* Source code: [sapi/embed/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/embed/CMakeLists.txt)

# The embed SAPI

Configure the `embed` PHP SAPI.

## PHP_SAPI_EMBED

* Default: `OFF`
* Values: `ON|OFF`

Enable the embedded PHP SAPI module for embedding PHP into application using C
bindings.

The embed library is after the build phase located in the `sapi/embed`
directory:

* as a shared library `libphp.so` (\*nix), or `libphp.dylib` (macOS), or
  `phpembed.dll` (Windows)
* and a static library `libphp.a` (\*nix), or `phpembed.lib` (Windows)

which can be further used in other applications. It exposes PHP API as C library
for other programs to use PHP.
