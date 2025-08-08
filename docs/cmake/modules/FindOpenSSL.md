<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindOpenSSL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindOpenSSL.cmake)

# FindOpenSSL

This module overrides the upstream CMake `FindOpenSSL` module with few
customizations:

* Added OpenSSL_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindOpenSSL.html

## Customizing search locations

To customize where to look for the OpenSSL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `OPENSSL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/OpenSSL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DOPENSSL_ROOT=/opt/OpenSSL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
