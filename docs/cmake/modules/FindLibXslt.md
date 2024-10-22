# FindLibXslt

See: [FindLibXslt.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindLibXslt.cmake)

Find the XSLT library (LibXslt).

See: https://cmake.org/cmake/help/latest/module/FindLibXslt.html

Module overrides the upstream CMake `FindLibXslt` module with few
customizations:

* Marked `LIBXSLT_EXSLT_INCLUDE_DIR` and `LIBXSLT_LIBRARY` as advanced variables
  (fixed upstream in CMake 3.28).

Hints:

The `LibXslt_ROOT` variable adds custom search path.
