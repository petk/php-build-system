<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindGcov.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGcov.cmake)

# FindGcov

Find the Gcov coverage programs and features.

Module defines the following `IMPORTED` target(s):

* `Gcov::Gcov` - The package library, if found.

## Result variables

* `Gcov_FOUND` - Whether the package has been found.

## Cache variables

* `Gcov_GCOVR_EXECUTABLE` - The gcovr program executable.
* `Gcov_GENHTML_EXECUTABLE` - The genhtml program executable.
* `Gcov_LCOV_EXECUTABLE` - The lcov program executable.

## Macros provided by this module

Module exposes the following macro that generates HTML coverage report:

```cmake
gcov_generate_report()
```

## Usage

```cmake
# CMakeLists.txt
find_package(Gcov)
```

## Customizing search locations

To customize where to look for the Gcov package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `GCOV_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Gcov;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DGCOV_ROOT=/opt/Gcov \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
