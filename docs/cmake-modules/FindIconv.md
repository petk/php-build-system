# FindIconv

See: [FindIconv.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindIconv.cmake)

Find the Iconv library.

See: https://cmake.org/cmake/help/latest/module/FindIconv.html

Module overrides the upstream CMake `FindIconv` module with few customizations.

Includes a customization for Alpine where GNU libiconv headers are located in
`/usr/include/gnu-libiconv` (fixed in CMake 3.31):
https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9774

Hints:

The `Iconv_ROOT` variable adds custom search path.
