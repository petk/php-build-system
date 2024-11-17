<!-- This is auto-generated file. -->
* Source code: [sapi/apache2handler/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/apache2handler/CMakeLists.txt)

# The apache2handler SAPI

Configure the `apache2handler` PHP SAPI.

## SAPI_APACHE2HANDLER

* Default: `OFF`
* Values: `ON|OFF`

Enable the shared Apache 2 handler SAPI module.

Loadable via Apache's Dynamic Shared Object (DSO) support; If Apache will use
PHP with one of the threaded Multi-Processing Modules (MPMs), PHP must be
configured and built with `PHP_THREAD_SAFETY` set to `ON`. Thread safety will
be set automatically during the configuration step, if threaded Apache can be
discovered on the system.

With `Apache_ROOT` and `Apache_APXS_EXECUTABLE` variables, path where to look
for the Apache installation on the system can be customized.
