<!-- This is auto-generated file. -->
* Source code: [sapi/apache2handler/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/apache2handler/CMakeLists.txt)

# The apache2handler SAPI

Configure the `apache2handler` PHP SAPI.

## Configuration options

### PHP_SAPI_APACHE2HANDLER

* Default: `OFF`
* Values: `ON|OFF`

Enable the shared Apache 2 handler SAPI module.

### PHP_SAPI_APACHE2HANDLER_INSTALL_DIR

* Default: The path to the Apache modules directory of the host system
  (`Apache_LIBEXEC`).

The path where to install the PHP Apache module (`mod_php.so`). Relative path is
interpreted as being relative to the installation prefix `CMAKE_INSTALL_PREFIX`.

## About

Loadable via Apache's Dynamic Shared Object (DSO) support. If Apache will use
PHP together with one of the threaded Multi-Processing Modules (MPMs), PHP must
be configured and built with `PHP_THREAD_SAFETY` set to `ON`. Thread safety will
be set automatically during the configuration step, if threaded Apache can be
discovered on the system.

Path where to look for the Apache installation on the system can be customized
with the `APACHE_ROOT` and `Apache_APXS_EXECUTABLE` variables.

For example:

```sh
cmake -B php-build -DPHP_SAPI_APACHE2HANDLER=ON -DAPACHE_ROOT=/opt/apache2
# or
cmake -B php-build -DPHP_SAPI_APACHE2HANDLER=ON -DApache_EXECUTABLE=/opt/apache2/bin/apxs
```

The path, where to install the PHP Apache module, can be overridden with the
`PHP_SAPI_APACHE2HANDLER_INSTALL_DIR` variable. This might be used in edge cases
where some specific custom installation prefix is used to avoid insuficcient
permissions of the default location on the host, or when developing the PHP
build system.

```sh
cmake \
  -B <build-dir> \
  -DPHP_SAPI_APACHE2HANDLER=ON \
  -DPHP_SAPI_APACHE2HANDLER_INSTALL_DIR=/custom/path/to/lib/apache2/modules
```
