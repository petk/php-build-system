<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCURL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCURL.cmake)

# FindCURL

This module overrides the upstream CMake `FindCURL` module with few
customizations:

* Fixed CURL static library.

  When using the `CURL_USE_STATIC_LIBS` hint variable, the upstream module
  doesn't find static library properly. If CURL is found in *config mode*, the
  upstream CURL config files don't provide the `CURL_USE_STATIC_LIBS` hint
  variable. This module bypasses this issue by providing additional imported
  target:

  * `CURL::CURL` - Target encapsulating curl library usage requirements,
    available if curl is found. Contains either shared curl library or when the
    `CURL_USE_STATIC_LIBS` hint variable is set to boolean true, it contains the
    static curl library.

See also:

* https://cmake.org/cmake/help/latest/module/FindCURL.html
* https://gitlab.kitware.com/cmake/cmake/-/issues/25994

## Customizing search locations

To customize where to look for the CURL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CURL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/CURL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCURL_ROOT=/opt/CURL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
