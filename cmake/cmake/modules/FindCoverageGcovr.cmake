#[=============================================================================[
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
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  CoverageGcovr
  PROPERTIES
    URL "https://gcovr.com"
    DESCRIPTION "Code coverage reporting tool (gcovr)"
)

block(
  PROPAGATE
    CoverageGcovr_FOUND
    CoverageGcovr_OPTIONS
    CoverageGcovr_VERSION
)
  set(reason "")
  set(required_vars "")

  ##############################################################################
  # Find gcov or llvm-cov tool.
  ##############################################################################

  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    string(REGEX MATCH "^[0-9]+" major_version "${CMAKE_C_COMPILER_VERSION}")

    find_program(
      Coverage_GCOV_EXECUTABLE
      NAMES gcov-${major_version} gcov
      DOC "Path to the GNU gcov coverage testing tool"
    )
    mark_as_advanced(Coverage_GCOV_EXECUTABLE)
  elseif(CMAKE_C_COMPILER_ID MATCHES "Clang")
    string(REGEX MATCH "^[0-9]+" major_version "${CMAKE_C_COMPILER_VERSION}")

    find_program(
      Coverage_LLVM_COV_EXECUTABLE
      NAMES llvm-cov-${major_version} llvm-cov
      DOC "Path to the LLVM cov coverage testing tool"
    )
    mark_as_advanced(Coverage_LLVM_COV_EXECUTABLE)
  endif()

  ##############################################################################
  # Find gcovr.
  ##############################################################################

  list(APPEND required_vars CoverageGcovr_EXECUTABLE)

  find_program(
    CoverageGcovr_EXECUTABLE
    NAMES gcovr
    DOC "Path to the generator for simple coverage reports"
  )
  mark_as_advanced(CoverageGcovr_EXECUTABLE)

  if(NOT CoverageGcovr_EXECUTABLE)
    string(APPEND reason "Required gcovr program was not found. ")
  endif()

  # Get version.
  if(IS_EXECUTABLE "${CoverageGcovr_EXECUTABLE}")
    execute_process(
      COMMAND ${CoverageGcovr_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(result EQUAL 0 AND version MATCHES "gcovr ([^\r\n]+)")
      set(CoverageGcovr_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(CMAKE_C_COMPILER_ID STREQUAL "GNU" AND Coverage_GCOV_EXECUTABLE)
    set(
      CoverageGcovr_OPTIONS
      --gcov-executable
      "${Coverage_GCOV_EXECUTABLE}"
    )
  elseif(
    CMAKE_C_COMPILER_ID MATCHES ".*Clang$"
    AND Coverage_LLVM_COV_EXECUTABLE
  )
    set(
      CoverageGcovr_OPTIONS
      --gcov-executable
      "${Coverage_LLVM_COV_EXECUTABLE} gcov"
    )
  endif()

  ##############################################################################

  find_package_handle_standard_args(
    CoverageGcovr
    REQUIRED_VARS ${required_vars}
    VERSION_VAR CoverageGcovr_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )

  ##############################################################################
  # Add imported targets.
  ##############################################################################

  if(CoverageGcovr_FOUND AND NOT TARGET CoverageGcovr::gcovr)
    add_executable(CoverageGcovr::gcovr IMPORTED)

    set_target_properties(
      CoverageGcovr::gcovr
      PROPERTIES
        IMPORTED_LOCATION "${CoverageGcovr_EXECUTABLE}"
    )
  endif()
endblock()
