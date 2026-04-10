<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCoverageLcov.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCoverageLcov.cmake)

# FindCoverageLcov

Finds the lcov tool by Linux Test Project (LTP):

```cmake
find_package(CoverageLcov [<version>] [COMPONENTS <components>...] [...])
```

Supported compilers:

* Clang
* GNU

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  CoverageLcov
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `lcov`

  Finds `lcov` executable.

* `genhtml`

  Finds LCOV's `genhtml` executable.

If no components are specified, by default, the `lcov` and `genthml` components
are searched.

## Imported targets

This module provides the following imported targets:

* `CoverageLcov::lcov`

  Imported executable target providing usage requirements for running the `lcov`
  executable. This target is available only if the `lcov` component was
  found.

* `CoverageLcov::genhtml`

  Imported executable target providing usage requirements for running the LCOV's
  `genhtml` executable. This target is available only if the `genhtml` component
  was found.

## Result variables

This module defines the following variables:

* `CoverageLcov_FOUND` - Boolean indicating whether requested coverage tools
  were found.
* `CoverageLcov_VERSION` - Version of the found `lcov`.
* `CoverageLcov_lcov_OPTIONS` - A list of command-line options for using `lcov`.

## Cache variables

The following cache variables may also be set:

* `CoverageLcov_EXECUTABLE` - The path to the `lcov` command-line executable.
* `CoverageLcov_GENHTML_EXECUTABLE` - The path to the `genhtml` command-line
  executable.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

find_package(Coverage)
find_package(CoverageLcov)

target_link_libraries(php_example PRIVATE Coverage::Coverage)

add_custom_target(
  php_example_generate_lcov_report
  DEPENDS php_example
  COMMAND CoverageLcov::lcov ${CoverageLcov_lcov_OPTIONS} ...
  COMMENT "[lcov] Generating coverage report"
  VERBATIM
)
```

## Customizing search locations

To customize where to look for the CoverageLcov package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `COVERAGELCOV_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/CoverageLcov;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCOVERAGELCOV_ROOT=/opt/CoverageLcov \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
