<!-- This is auto-generated file. -->
* Source code: [sapi/embed/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/embed/CMakeLists.txt)

# The embed SAPI

Configure the `embed` PHP SAPI.

## SAPI_EMBED

* Default: `OFF`
* Values: `ON|OFF`

Enable the embedded PHP SAPI module.

The embed library is then located in the `sapi/embed` directory as a shared
library `libphp.so`, or a static library `libphp.a`, which can be further used
in other applications. It exposes PHP API as C library object for other programs
to use PHP.
