<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCoverage.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCoverage.cmake)

# FindCoverage

Finds the code coverage compiler features:

```cmake
find_package(Coverage [...])
```

## Introduction

This module checks whether the current compiler supports certain code coverage
options to build binaries with code coverage enabled and their belonging files.

Supported compilers:

* GNU
* Clang

### gcov-based code coverage

This is a GCC-compatible coverage implementation which operates on DebugInfo. It
is supported by GNU and Clang compilers.

In general, to generate code coverage reports source code must be compiled with
compiler option `--coverage` (available since GNU compiler 4.1 and Clang 2.6.0).
This automatically uses the `-ftest-coverage` and `-fprofile-arcs` options.

With enabled code coverage, compiler produces two additional types of files:

* `.gcno` notes files during compilation of source files when compiling with the
  `-ftest-coverage` option.
* `.gcda` data files during the runtime when the built programs are compiled
  with `-fprofile-arcs` and they are executed. These are normally generated when
  running tests.

With these generated files tools like `gcovr` or `lcov` can then generate
coverage reports.

### Clang's source-based code coverage

When using Clang compiler, it provides its own native implementation of code
coverage using the `-fprofile-instr-generate` and `-fcoverage-mapping` options.
When source files are built with these options `*.profraw` files are generated
during the program runtime (e.g., when running tests). These files can be then
used to generate HTML report.

## Imported targets

This module provides the following imported targets:

* `Coverage::Coverage`

  Interface imported target providing usage requirements to generate code
  coverage notes and data files. This target is available as long as a
  compatible C compiler is used.

## Result variables

This module defines the following variables:

* `Coverage_FOUND` - Boolean indicating whether the compiler supports code
  coverage features.

## Cache variables

The following cache variables may also be set:

* `Coverage_LLVM_PROFDATA_EXECUTABLE` - Path to the Clang's profile data tool.
  This is set when using Clang compiler.
* `Coverage_LLVM_COV_EXECUTABLE` - Path to the Clang's tool that emits coverage
  information. This is set when using Clang compiler.

## Hints

This module accepts the following variables before calling `find_package()`:

* `Coverage_LLVM_GCOV` - Set this variable to boolean true when using Clang
  compiler to use the gcov code coverage (`--coverage`) instead of its native
  source-based code coverage (`-fprofile-instr-generate` and
  `-fcoverage-mapping`). Note that Clang might have issues with gcov-based code
  coverage as development there is focused on their source-based coverage.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

find_package(Coverage)

target_link_libraries(php_example PRIVATE Coverage::Coverage)
```

## Customizing search locations

To customize where to look for the Coverage package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `COVERAGE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Coverage;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCOVERAGE_ROOT=/opt/Coverage \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
