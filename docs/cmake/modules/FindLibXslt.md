<!-- This is auto-generated file. -->
# FindLibXslt

* Module source code: [FindLibXslt.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindLibXslt.cmake)

Find the XSLT library (LibXslt).

See: https://cmake.org/cmake/help/latest/module/FindLibXslt.html

Module overrides the upstream CMake `FindLibXslt` module with few
customizations:

* Marked `LIBXSLT_EXSLT_INCLUDE_DIR` and `LIBXSLT_LIBRARY` as advanced variables
  (fixed upstream in CMake 3.28).

## Basic usage

```cmake
# CMakeLists.txt
find_package(LibXslt)
```

## Customizing search locations

To customize where to look for the LibXslt package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LIBXSLT_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/LibXslt;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DLIBXSLT_ROOT=/opt/LibXslt \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
