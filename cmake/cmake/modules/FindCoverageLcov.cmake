#[=============================================================================[
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
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  CoverageLcov
  PROPERTIES
    URL "https://github.com/linux-test-project/lcov"
    DESCRIPTION "Code coverage reporting tools (lcov, genhtml)"
)

block(
  PROPAGATE
    CoverageLcov_FOUND
    CoverageLcov_lcov_OPTIONS
    CoverageLcov_VERSION
)
  set(reason "")
  set(required_vars "")

  # Set default components.
  if(NOT CoverageLcov_FIND_COMPONENTS)
    set(CoverageLcov_FIND_COMPONENTS lcov genhtml)
  endif()

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
  # Find lcov.
  ##############################################################################

  if("lcov" IN_LIST CoverageLcov_FIND_COMPONENTS)
    list(APPEND required_vars CoverageLcov_EXECUTABLE)

    find_program(
      CoverageLcov_EXECUTABLE
      NAMES lcov
      DOC "Path to the graphical GCOV front-end"
    )
    mark_as_advanced(CoverageLcov_EXECUTABLE)

    if(NOT CoverageLcov_EXECUTABLE)
      string(APPEND reason "Required lcov program was not found. ")
    endif()

    if(CMAKE_C_COMPILER_ID STREQUAL "GNU" AND Coverage_GCOV_EXECUTABLE)
      set(
        CoverageLcov_lcov_OPTIONS
        --gcov-tool
        ${Coverage_GCOV_EXECUTABLE}
      )
    elseif(
      CMAKE_C_COMPILER_ID MATCHES ".*Clang$"
      AND Coverage_LLVM_COV_EXECUTABLE
    )
      set(
        CoverageLcov_lcov_OPTIONS
        --gcov-tool
        ${Coverage_LLVM_COV_EXECUTABLE},gcov
      )
    endif()

    if(CoverageLcov_EXECUTABLE)
      set(CoverageLcov_lcov_FOUND TRUE)
    else()
      set(CoverageLcov_lcov_FOUND FALSE)
    endif()
  endif()

  ##############################################################################
  # Find genhtml.
  ##############################################################################

  if("genhtml" IN_LIST CoverageLcov_FIND_COMPONENTS)
    list(APPEND required_vars CoverageLcov_GENHTML_EXECUTABLE)

    find_program(
      CoverageLcov_GENHTML_EXECUTABLE
      NAMES genhtml
      DOC "Path to the generator for HTML view from LCOV coverage data files"
    )
    mark_as_advanced(CoverageLcov_GENHTML_EXECUTABLE)

    if(NOT CoverageLcov_GENHTML_EXECUTABLE)
      string(APPEND reason "Required genhtml program was not found. ")
    endif()

    if(CoverageLcov_GENHTML_EXECUTABLE)
      set(CoverageLcov_genhtml_FOUND TRUE)
    else()
      set(CoverageLcov_genhtml_FOUND FALSE)
    endif()
  endif()

  ##############################################################################
  # Get version.
  ##############################################################################

  if(IS_EXECUTABLE "${CoverageLcov_EXECUTABLE}")
    set(executable "${CoverageLcov_EXECUTABLE}")
  elseif(IS_EXECUTABLE "${CoverageLcov_GENHTML_EXECUTABLE}")
    set(executable "${CoverageLcov_GENHTML_EXECUTABLE}")
  else()
    set(executable "")
  endif()

  if(executable)
    execute_process(
      COMMAND ${executable} --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(result EQUAL 0 AND version MATCHES "LCOV version ([^\r\n]+)")
      set(CoverageLcov_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(DEFINED CoverageLcov_VERSION)
    find_package_check_version(
      "${CoverageLcov_VERSION}"
      result
      HANDLE_VERSION_RANGE
      RESULT_MESSAGE_VARIABLE version_reason
    )

    if(NOT result)
      string(APPEND reason "${version_reason} ")
      set(CoverageLcov_lcov_FOUND FALSE)
      set(CoverageLcov_genhtml_FOUND FALSE)
    endif()
  endif()

  ##############################################################################

  find_package_handle_standard_args(
    CoverageLcov
    REQUIRED_VARS ${required_vars}
    VERSION_VAR CoverageLcov_VERSION
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
    REASON_FAILURE_MESSAGE "${reason}"
  )

  ##############################################################################
  # Add imported targets.
  ##############################################################################

  if(
    CoverageLcov_lcov_FOUND
    AND NOT TARGET CoverageLcov::lcov
    AND "lcov" IN_LIST CoverageLcov_FIND_COMPONENTS
  )
    add_executable(CoverageLcov::lcov IMPORTED)

    set_target_properties(
      CoverageLcov::lcov
      PROPERTIES
        IMPORTED_LOCATION "${CoverageLcov_EXECUTABLE}"
    )
  endif()

  if(
    CoverageLcov_genhtml_FOUND
    AND NOT TARGET CoverageLcov::genhtml
    AND "genhtml" IN_LIST CoverageLcov_FIND_COMPONENTS
  )
    add_executable(CoverageLcov::genhtml IMPORTED)

    set_target_properties(
      CoverageLcov::genhtml
      PROPERTIES
        IMPORTED_LOCATION "${CoverageLcov_GENHTML_EXECUTABLE}"
    )
  endif()
endblock()
