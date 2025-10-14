<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindGcov.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindGcov.cmake)

# FindGcov

Finds the Gcov coverage programs and features:

```cmake
find_package(Gcov)
```

## Imported targets

This module provides the following imported targets:

* `Gcov::Gcov` - The package library, if found.

## Result variables

This module defines the following variables:

* `Gcov_FOUND` - Boolean indicating whether the package was found.

## Cache variables

The following cache variables may also be set:

* `Gcov_GCOVR_EXECUTABLE` - The gcovr program executable.
* `Gcov_GENHTML_EXECUTABLE` - The genhtml program executable.
* `Gcov_LCOV_EXECUTABLE` - The lcov program executable.

## Macros provided by this module

Module exposes the following macro that generates HTML coverage report:

```cmake
gcov_generate_report()
```

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Gcov)
target_link_libraries(example PRIVATE Gcov::Gcov)
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
