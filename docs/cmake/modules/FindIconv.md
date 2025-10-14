<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindIconv.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindIconv.cmake)

# FindIconv

This module overrides the upstream CMake `FindIconv` module with few
customizations:

* Included a customization for Alpine where GNU libiconv headers are located in
  `/usr/include/gnu-libiconv` (fixed in CMake 3.31):
  https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9774

* Added adjustment when the iconv library installation path is manually set,
  otherwise Iconv is first searched in the C library.

See: https://cmake.org/cmake/help/latest/module/FindIconv.html

## Customizing search locations

To customize where to look for the Iconv package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ICONV_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Iconv;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DICONV_ROOT=/opt/Iconv \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
