<!-- This is auto-generated file. -->
* Source code: [sapi/apache2handler/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/apache2handler/CMakeLists.txt)

# The apache2handler SAPI

## Configuration options

### PHP_SAPI_APACHE2HANDLER

* Default: `OFF`
* Values: `ON|OFF`

Enables the shared Apache 2 handler SAPI module.

### PHP_SAPI_APACHE2HANDLER_INSTALL_DIR

* Default: The path to the Apache modules directory of the host system
  (`Apache_LIBEXEC`).

The path where to install the PHP Apache module (`mod_php.so`). Relative path is
interpreted as being relative to the installation prefix `CMAKE_INSTALL_PREFIX`.

## About

Loadable via Apache's Dynamic Shared Object (DSO) support. If Apache will use
PHP together with one of the threaded Multi-Processing Modules (MPMs), PHP must
be configured and built with `PHP_THREAD_SAFETY` set to `ON`. If threaded Apache
is found on the system and PHP thread safety is not enabled during the
configuration phase fatal error is emitted.

## Examples

The path where to look for the Apache installation on the system can be
customized with the `APACHE_ROOT` or `CMAKE_PREFIX_PATH` variables.

```sh
cmake -B php-build -DPHP_SAPI_APACHE2HANDLER=ON -DAPACHE_ROOT=/opt/apache2
# or
cmake -B php-build -DPHP_SAPI_APACHE2HANDLER=ON -DCMAKE_PREFIX_PATH=/opt/apache2
```

The path, where to install the PHP Apache module, can be overridden with the
`PHP_SAPI_APACHE2HANDLER_INSTALL_DIR` variable. This might be used in edge cases
where some specific custom installation prefix is used to avoid insufficient
permissions of the default location on the host, or when developing the PHP
build system.

```sh
cmake \
  -B <build-dir> \
  -DPHP_SAPI_APACHE2HANDLER=ON \
  -DPHP_SAPI_APACHE2HANDLER_INSTALL_DIR=/custom/path/to/lib/apache2/modules
```
