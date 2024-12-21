#[=============================================================================[
# FindBISON

Find the bison utility.

See: https://cmake.org/cmake/help/latest/module/FindBISON.html

This module overrides the upstream CMake `FindBISON` module with few
customizations.

A new `bison_generate()` function is added to be able to use it in command-line
scripts.

```cmake
bison_generate(
  <name>
  <input>
  <output>
  [COMPILE_OPTIONS <flags>]
  [DEFINES_FILE <file>]
  [VERBOSE [REPORT_FILE <file>]]
)
```
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  BISON
  PROPERTIES
    URL "https://www.gnu.org/software/bison/"
    DESCRIPTION "General-purpose parser generator"
)

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindBISON)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)

if(NOT BISON_FOUND)
  return()
endif()

function(bison_generate)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "VERBOSE" # options
    "DEFINES_FILE;REPORT_FILE" # one-value keywords
    "COMPILE_OPTIONS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  set(input ${ARGV1})
  if(NOT IS_ABSOLUTE "${input}")
    set(input ${CMAKE_CURRENT_SOURCE_DIR}/${input})
  endif()

  set(output ${ARGV2})
  if(NOT IS_ABSOLUTE "${output}")
    set(output ${CMAKE_CURRENT_BINARY_DIR}/${output})
  endif()

  set(options ${parsed_OPTIONS})

  message(
    STATUS
    "[BISON][${ARGV0}] Generating parser with bison ${BISON_VERSION}"
  )

  execute_process(COMMAND ${BISON_EXECUTABLE} ${options} -o ${output} ${input})
endfunction()
