# `SAPI_EMBED`

* Default: `OFF`
* Values: `ON|OFF`

Enable the Embed SAPI module.

The embed library is then located in the `sapi/embed` directory as a shared
library `libphp.so`, or a static library `libphp.a`, which can be further used
in other applications. It exposes PHP API as C library object for other programs
to use PHP.
