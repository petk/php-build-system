<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindBZip2.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindBZip2.cmake)

# FindBZip2

This module overrides the upstream CMake `FindBZip2` module with few
customizations:

* Added BZip2_VERSION result variable for CMake < 4.2.

See: https://cmake.org/cmake/help/latest/module/FindBZip2.html

## Customizing search locations

To customize where to look for the BZip2 package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `BZIP2_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/BZip2;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DBZIP2_ROOT=/opt/BZip2 \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
