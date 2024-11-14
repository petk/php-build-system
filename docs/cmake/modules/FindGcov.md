# FindGcov

See: [FindGcov.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGcov.cmake)

## Basic usage

```cmake
find_package(Gcov)
```

Find the Gcov coverage programs and features.

Module defines the following `IMPORTED` target(s):

* `Gcov::Gcov` - The package library, if found.

Result variables:

* `Gcov_FOUND` - Whether the package has been found.

Cache variables:

* `Gcov_GCOVR_EXECUTABLE` - The gcovr program executable.
* `Gcov_GENHTML_EXECUTABLE` - The genhtml program executable.
* `Gcov_LCOV_EXECUTABLE` - The lcov program executable.
* `HAVE_GCOV` - Whether the Gcov is available.

Hints:

The `Gcov_ROOT` variable adds custom search path.

Module exposes the following macro that generates HTML coverage report:

```cmake
gcov_generate_report()
```
