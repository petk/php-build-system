#[=============================================================================[
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
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Gcov
  PROPERTIES
    DESCRIPTION "Coverage report - gcov and lcov"
)

set(_reason "")

# TODO: Remove all optimization flags.

find_program(
  Gcov_LCOV_EXECUTABLE
  NAMES lcov
  DOC "Path to the graphical GCOV front-end"
)

find_program(
  Gcov_GENHTML_EXECUTABLE
  NAMES genhtml
  DOC "Path to the generator for HTML view from LCOV coverage data files"
)

find_program(
  Gcov_GCOVR_EXECUTABLE
  NAMES gcovr
  DOC "Path to the generator for simple coverage reports"
)

if(NOT Gcov_LCOV_EXECUTABLE)
  string(APPEND _reason "Required lcov program was not found. ")
endif()

if(NOT Gcov_GENHTML_EXECUTABLE)
  string(APPEND _reason "Required genhtml program was not found. ")
endif()

if(NOT Gcov_GCOVR_EXECUTABLE)
  string(APPEND _reason "Required gcovr program was not found. ")
endif()

mark_as_advanced(
  Gcov_GCOVR_EXECUTABLE
  Gcov_GENHTML_EXECUTABLE
  Gcov_LCOV_EXECUTABLE
)

find_package_handle_standard_args(
  Gcov
  REQUIRED_VARS
    Gcov_GCOVR_EXECUTABLE
    Gcov_GENHTML_EXECUTABLE
    Gcov_LCOV_EXECUTABLE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(Gcov_FOUND AND NOT TARGET Gcov::Gcov)
  add_library(Gcov::Gcov INTERFACE IMPORTED)

  set_target_properties(
    Gcov::Gcov
    PROPERTIES
      # Add the special GCC flags.
      INTERFACE_COMPILE_OPTIONS
        "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fprofile-arcs;-ftest-coverage>"
      INTERFACE_LINK_OPTIONS
        "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:-lgcov;--coverage>"
  )
endif()

macro(gcov_generate_report)
  file(
    GENERATE
    OUTPUT CMakeFiles/GenerateGcovReport.cmake
    CONTENT "
      message(STATUS \"Generating lcov data for php_lcov.info\")
      execute_process(
        COMMAND
          ${Gcov_LCOV_EXECUTABLE}
          --capture
          --no-external
          --directory ${PROJECT_BINARY_DIR}
          --output-file ${PROJECT_BINARY_DIR}/php_lcov.info
      )

      message(STATUS \"Stripping bundled libraries from php_lcov.info\")
      execute_process(
        COMMAND
          ${Gcov_LCOV_EXECUTABLE}
          --output-file ${PROJECT_BINARY_DIR}/php_lcov.info
          --remove ${PROJECT_BINARY_DIR}/php_lcov.info */<stdout>
            ${PROJECT_BINARY_DIR}/ext/bcmath/libbcmath/*
            ${PROJECT_BINARY_DIR}/ext/date/lib/*
            */ext/date/lib/parse_date.re
            */ext/date/lib/parse_iso_intervals.re
            ${PROJECT_BINARY_DIR}/ext/fileinfo/libmagic/*
            ${PROJECT_BINARY_DIR}/ext/gd/libgd/*
            ${PROJECT_BINARY_DIR}/ext/hash/sha3/*
            ${PROJECT_BINARY_DIR}/ext/mbstring/libmbfl/*
            ${PROJECT_BINARY_DIR}/ext/pcre/pcre2lib/*
      )

      message(STATUS \"Generating lcov HTML\")
      execute_process(
        COMMAND
          ${Gcov_GENHTML_EXECUTABLE}
          --legend
          --output-directory ${PROJECT_BINARY_DIR}/lcov_html
          --title \"PHP Code Coverage\"
          ${PROJECT_BINARY_DIR}/php_lcov.info
      )

      message(STATUS \"Generating gcovr HTML\")
      # Clean generated gcovr_html directory. Checks are done as safeguards.
      if(
        EXISTS ${PROJECT_BINARY_DIR}/main/internal_functions.c
        AND EXISTS ${PROJECT_BINARY_DIR}/gcovr_html
      )
        file(REMOVE_RECURSE ${PROJECT_BINARY_DIR}/gcovr_html)
      endif()
      file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/gcovr_html)
      execute_process(
        COMMAND
          ${Gcov_GCOVR_EXECUTABLE}
          -sr ${PROJECT_BINARY_DIR}
          -o ${PROJECT_BINARY_DIR}/gcovr_html/index.html
          --html
          --html-details
          --exclude-directories .*date.dir/lib\\\$
          -e ext/bcmath/libbcmath/.*
          -e ext/fileinfo/libmagic/.*
          -e ext/gd/libgd/.*
          -e ext/hash/sha3/.*
          -e ext/mbstring/libmbfl/.*
          -e ext/pcre/pcre2lib/.*
      )

      message(STATUS \"Generating gcovr XML\")
      # Clean generated gcovr.xml file. Checks are done as safeguards.
      if(
        EXISTS ${PROJECT_BINARY_DIR}/main/internal_functions.c
        AND EXISTS ${PROJECT_BINARY_DIR}/gcovr.xml
      )
        file(REMOVE ${PROJECT_BINARY_DIR}/gcovr.xml)
      endif()
      execute_process(
        COMMAND
          ${Gcov_GCOVR_EXECUTABLE}
          -sr ${PROJECT_BINARY_DIR}
          -o ${PROJECT_BINARY_DIR}/gcovr.xml
          --xml
          --exclude-directories .*date.dir/lib\\\$
          -e ext/bcmath/libbcmath/.*
          -e ext/fileinfo/libmagic/.*
          -e ext/gd/libgd/.*
          -e ext/hash/sha3/.*
          -e ext/mbstring/libmbfl/.*
          -e ext/pcre/pcre2lib/.*
      )
    "
  )

  # Create a list of PHP SAPIs with genex for usage in the add_custom_command.
  block(PROPAGATE sapis)
    set(sapis "")
    file(GLOB directories ${PROJECT_SOURCE_DIR}/sapi/*)
    foreach(dir ${directories})
      cmake_path(GET dir FILENAME sapi)
      list(APPEND sapis "$<TARGET_NAME_IF_EXISTS:php_sapi_${sapi}>")
    endforeach()
  endblock()

  add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/php_lcov.info
    COMMAND ${CMAKE_COMMAND} -P "CMakeFiles/GenerateGcovReport.cmake"
    DEPENDS ${sapis}
    COMMENT "[GCOV] Generating GCOV coverage report"
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  unset(sapis)

  # Create target which consumes the command via DEPENDS.
  add_custom_target(
    gcov ALL
    DEPENDS ${PROJECT_BINARY_DIR}/php_lcov.info
    COMMENT "[GCOV] Generating GCOV files"
  )
endmacro()
