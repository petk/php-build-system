<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCoverageGcovr.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCoverageGcovr.cmake)

# FindCoverageGcovr

Finds the gcovr code coverage program:

```cmake
find_package(CoverageGcovr [<version>] [...])
```

Supported compilers:

* Clang
* GNU

## Imported targets

This module provides the following imported targets:

* `CoverageGcovr::gcovr`

  Imported executable target providing usage requirements for running the
  `gcovr` executable.

## Result variables

This module defines the following variables:

* `CoverageGcovr_FOUND` - Boolean indicating whether gcovr coverage tool was
  found.
* `CoverageGcovr_VERSION` - Version of the found `gcovr`.
* `CoverageGcovr_OPTIONS` - A list of command-line options for using `gcovr`.

## Cache variables

The following cache variables may also be set:

* `CoverageGcovr_EXECUTABLE` - The gcovr program executable.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

find_package(Coverage)
find_package(CoverageGcovr)

target_link_libraries(php_example PRIVATE Coverage::Coverage)

add_custom_target(
  php_example_generate_gcovr_report
  DEPENDS php_example
  COMMAND CoverageGcovr::gcovr ${CoverageGcovr_OPTIONS} ...
  COMMENT "[gcovr] Generating gcovr report"
  VERBATIM
)
```

## Customizing search locations

To customize where to look for the CoverageGcovr package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `COVERAGEGCOVR_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/CoverageGcovr;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCOVERAGEGCOVR_ROOT=/opt/CoverageGcovr \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
