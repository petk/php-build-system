<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindBISON.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindBISON.cmake)

# FindBISON

This module extends the upstream CMake `FindBISON` module with few
customizations.

See: https://cmake.org/cmake/help/latest/module/FindBISON.html

## Customizing search locations

To customize where to look for the BISON package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `BISON_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/BISON;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DBISON_ROOT=/opt/BISON \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
