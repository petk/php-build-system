#[=============================================================================[
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
  coverate features.

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
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Coverage
  PROPERTIES
    DESCRIPTION "Code coverage"
)

if(CMAKE_C_COMPILER_LAUNCHER MATCHES "ccache")
  message(
    WARNING
    "When 'PHP_COVERAGE' is enabled, ccache should be disabled by setting the "
    "'PHP_CCACHE' to 'OFF' or by setting the 'CCACHE_DISABLE' environment "
    "variable."
  )
endif()

block(PROPAGATE Coverage_FOUND)
  set(reason "")

  if(CMAKE_C_COMPILER_ID MATCHES "^(.*Clang|GNU)$")
    set(has_supported_compiler TRUE)
  else()
    set(has_supported_compiler FALSE)

    set(compiler_info "${CMAKE_C_COMPILER_ID}")
    if(CMAKE_C_COMPILER_VERSION)
      string(APPEND compiler_info " version ${CMAKE_C_COMPILER_VERSION}")
    endif()
    string(APPEND compiler_info " (${CMAKE_C_COMPILER})")

    string(
      APPEND
      reason
      "C compiler ${compiler_info} is not supported to enable code coverage, "
      "please use GNU or Clang compiler instead. "
    )
  endif()

  if(CMAKE_C_COMPILER MATCHES "Clang")
    string(REGEX MATCH "^[0-9]+" major_version "${CMAKE_C_COMPILER_VERSION}")

    find_program(
      Coverage_LLVM_PROFDATA_EXECUTABLE
      NAMES llvm-profdata-${major_version} llvm-profdata
      DOC "Path to the Clang's profile data tool (llvm-profdata executable)"
    )
    mark_as_advanced(Coverage_LLVM_PROFDATA_EXECUTABLE)

    find_program(
      Coverage_LLVM_COV_EXECUTABLE
      NAMES llvm-cov-${major_version} llvm-cov
      DOC "Path to the LLVM cov coverage testing tool"
    )
    mark_as_advanced(Coverage_LLVM_COV_EXECUTABLE)
  endif()

  ##############################################################################

  find_package_handle_standard_args(
    Coverage
    REQUIRED_VARS has_supported_compiler
    REASON_FAILURE_MESSAGE "${reason}"
  )

  ##############################################################################
  # Add imported targets.
  ##############################################################################

  if(Coverage_FOUND AND NOT TARGET Coverage::Coverage)
    add_library(Coverage::Coverage INTERFACE IMPORTED)

    # PHP-specific compile definition.
    set_target_properties(
      Coverage::Coverage
      PROPERTIES INTERFACE_COMPILE_DEFINITIONS HAVE_GCOV
    )

    if(CMAKE_C_COMPILER_ID MATCHES "Clang" AND NOT Coverage_LLVM_GCOV)
      set_target_properties(
        Coverage::Coverage
        PROPERTIES
          INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:C,CXX>:-fprofile-instr-generate=${CMAKE_CURRENT_BINARY_DIR}/coverage/$<TARGET_PROPERTY:NAME>_%p.profraw;-fcoverage-mapping>"
          INTERFACE_LINK_OPTIONS "$<$<LINK_LANGUAGE:C,CXX>:-fprofile-instr-generate=${CMAKE_CURRENT_BINARY_DIR}/coverage/$<TARGET_PROPERTY:NAME>_%p.profraw>"
      )
    else()
      set_target_properties(
        Coverage::Coverage
        PROPERTIES
          INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:C,CXX>:--coverage>"
          INTERFACE_LINK_OPTIONS "$<$<LINK_LANGUAGE:C,CXX>:--coverage>"
      )
    endif()
  endif()
endblock()
