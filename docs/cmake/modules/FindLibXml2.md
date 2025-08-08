<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindLibXml2.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindLibXml2.cmake)

# FindLibXml2

This module overrides the upstream CMake `FindLibXml2` module with few
customizations:

* Added LibXml2_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html

## Customizing search locations

To customize where to look for the LibXml2 package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LIBXML2_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/LibXml2;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DLIBXML2_ROOT=/opt/LibXml2 \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
