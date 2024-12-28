#[=============================================================================[
# FindBISON

Find `bison` command-line parser generator.

This is a standalone and customized find module for finding bison. It is synced
with CMake FindBISON module, where possible.
See also: https://cmake.org/cmake/help/latest/module/FindBISON.html

## Result variables

* `BISON_FOUND` - Whether the `bison` was found.
* `BISON_VERSION` - The `bison` version.

## Cache variables

* `BISON_EXECUTABLE` - Path to the `bison`.

## Hints

These variables can be set before calling the `find_package(BISON)`:

* `BISON_DEFAULT_OPTIONS` - A semicolon-separated list of default global bison
  options to be prepended to `bison(OPTIONS)` argument for all bison invocations
  when generating parser files.

* `BISON_DISABLE_DOWNLOAD` - Set to `TRUE` to disable downloading and building
  bison package from source, when it is not found on the system or found version
  is not suitable.

* `BISON_DOWNLOAD_VERSION` - Override the default `bison` version to be
  downloaded when not found on the system.

## Functions provided by this module

### `bison()`

Generate parser file `<output>` from the given `<input>` template file using the
`bison` parser generator.

```cmake
bison(
  <name>
  <input>
  <output>
  [HEADER | HEADER_FILE <header>]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [VERBOSE [REPORT_FILE <file>]]
  [NO_DEFAULT_OPTIONS]
  [CODEGEN]
  [WORKING_DIRECTORY <working-directory>]
)
```

This creates a custom CMake target `<name>` and adds a custom command that
generates parser file `<output>` from the given `<input>` template file using
the `bison` parser generator. Relative source file path `<input>` is interpreted
as being relative to the current source directory. Relative `<output>` file path
is interpreted as being relative to the current binary directory. If `bison` is
not a required package and it is not found, it will create a custom target but
skip the `bison` command execution.

When used in CMake command-line script mode (see `CMAKE_SCRIPT_MODE_FILE`) it
simply generates the parser without creating a target, to make it easier to use
in various scenarios.

#### Options

* `HEADER` - Produce also a header file automatically.

* `HEADER_FILE <header>` - Produce a header as a specified file `<header>`.
  Relative header file path is interpreted as being relative to the current
  binary directory.

* `OPTIONS <options>...` - Optional list of additional options to pass to the
  bison command-line tool.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `NO_DEFAULT_OPTIONS` - If specified, the `BISON_DEFAULT_OPTIONS` are not added
  to the current `bison` invocation.

* `CODEGEN` - Adds the `CODEGEN` option to the bison's `add_custom_command()`
  call. Works as of CMake 3.31 when policy `CMP0171` is set to `NEW`, which
  provides a global CMake `codegen` target for convenience to call only the
  code-generation-related targets and skips the majority of the build:

  ```sh
  cmake --build <dir> --target codegen
  ```

* `WORKING_DIRECTORY <working-directory>` - The path where the `bison` command
  is executed. By default, `bison` is executed in the current binary directory
  (`CMAKE_CURRENT_BINARY_DIR`). Relative `<working-directory>` path is
  interpreted as being relative to the current binary directory.

## Examples

### Minimum bison version

The minimum required `bison` version can be specified using the standard CMake
syntax, e.g.

```cmake
# CMakeLists.txt

find_package(BISON 3.0.0)
```

### Running bison

```cmake
# CMakeLists.txt

find_package(BISON)

# Commands provided by find modules must be called conditionally, because user
# can also disable the find module with CMAKE_DISABLE_FIND_PACKAGE_BISON.
if(BISON_FOUND)
  bison(...)
endif()
```

### Specifying options

Setting default options for all `bison()` calls in the scope of the
`find_package(BISON)`:

```cmake
# CMakeLists.txt

# Optionally, set default options for all bison invocations. For example, add
# option to suppress date output in the generated file:
set(BISON_DEFAULT_OPTIONS -Wall --no-lines)

find_package(BISON)

# This will execute bison as:
# bison -Wall --no-lines -d foo.y --output foo.c
if(BISON_FOUND)
  bison(foo foo.y foo.c OPTIONS -d)
endif()

# This will execute bison as:
# bison -l bar.y --output bar.c
if(BISON_FOUND)
  bison(bar bar.y bar.c OPTIONS -l)
endif()
```

Generator expressions are supported in `bison(OPTIONS)` when running it in the
`project()` mode:

```cmake
# CMakeLists.txt

find_package(BISON)

if(BISON_FOUND)
  bison(foo foo.y foo.c OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-lines>)
endif()
```

### Custom target usage

To specify dependencies with the custom target created by `bison()`:

```cmake
# CMakeLists.txt

find_package(BISON)

if(BISON_FOUND)
  bison(foo_parser parser.y parser.c)
  add_dependencies(some_target foo_parser)
endif()
```

Or to run only the specific `foo_parser` target, which generates the parser.

```sh
cmake --build <dir> --target foo_parser
```

### Script mode

When running `bison()` in script mode:

```sh
cmake -P script.cmake
```

the generated file is created right away:

```cmake
# script.cmake

find_package(BISON REQUIRED)

if(BISON_FOUND)
  bison(parser.y parser.c)
endif()
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

################################################################################
# Functions.
################################################################################

# Process options.
function(_bison_process_options options result)
  set(options ${${options}})

  if(BISON_DEFAULT_OPTIONS AND NOT parsed_NO_DEFAULT_OPTIONS)
    list(PREPEND options ${BISON_DEFAULT_OPTIONS})
  endif()

  set(${result} ${options})

  return(PROPAGATE ${result})
endfunction()

macro(_bison_process)
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
  cmake_path(SET input NORMALIZE "${input}")

  set(output ${ARGV2})
  if(NOT IS_ABSOLUTE "${output}")
    set(output ${CMAKE_CURRENT_BINARY_DIR}/${output})
  endif()
  cmake_path(SET output NORMALIZE "${output}")

  set(outputs ${output})

  _bison_process_options(parsed_OPTIONS options)

  if(parsed_HEADER OR parsed_HEADER_FILE)
    # Bison versions 3.8 and later introduced the --header=[FILE] (-H) option.
    # For prior versions the --defines=[FILE] (-d) option can be used.
    if(parsed_HEADER_FILE)
      set(header ${parsed_HEADER_FILE})
      if(NOT IS_ABSOLUTE "${header}")
        set(header ${CMAKE_CURRENT_BINARY_DIR}/${header})
      endif()
      if(BISON_VERSION VERSION_LESS 3.8)
        list(APPEND options --defines=${header})
      else()
        list(APPEND options --header=${header})
      endif()
    else()
      if(BISON_VERSION VERSION_LESS 3.8)
        list(APPEND options -d)
      else()
        list(APPEND options --header)
      endif()

      # Produce default header path generated by bison (see option --header)
      cmake_path(GET output EXTENSION LAST_ONLY extension)
      string(REPLACE "c" "h" extension "${extension}")
      if(NOT extension)
        set(extension "h")
      endif()
      cmake_path(
        REPLACE_EXTENSION
        output
        LAST_ONLY
        "${extension}"
        OUTPUT_VARIABLE header
      )
      # TODO: Add path if header is relative.
    endif()

    list(APPEND outputs ${header})

    if(parsed_VERBOSE)
      list(APPEND options --verbose)
      if(parsed_REPORT_FILE)
        if(NOT IS_ABSOLUTE "${parsed_REPORT_FILE}")
          set(
            parsed_REPORT_FILE
            ${CMAKE_CURRENT_BINARY_DIR}/${parsed_REPORT_FILE}
          )
        endif()
        list(APPEND options --report-file=${parsed_REPORT_FILE})
      endif()
    endif()
  endif()

  # Assemble commands for add_custom_command() and execute_process().
  set(commands "")

  # Bison cannot create output directories. Ensure any required directories for
  # the generated files are created if they don't already exist.
  set(directories "")
  foreach(output IN LISTS outputs)
    cmake_path(GET output PARENT_PATH dir)
    if(dir)
      list(APPEND directories ${dir})
    endif()
  endforeach()
  if(directories)
    list(REMOVE_DUPLICATES directories)
    list(
      APPEND
      commands
      COMMAND ${CMAKE_COMMAND} -E make_directory ${directories}
    )
  endif()

  list(
    APPEND
    commands
    COMMAND ${BISON_EXECUTABLE} ${options} ${input} --output ${output}
  )

  # Assemble status message.
  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE outputRelative
  )

  set(message "Generating ${outputRelative} with bison ${BISON_VERSION}")

  if(NOT parsed_WORKING_DIRECTORY)
    set(parsed_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  else()
    if(NOT IS_ABSOLUTE "${parsed_WORKING_DIRECTORY}")
      set(
        parsed_WORKING_DIRECTORY
        ${CMAKE_CURRENT_BINARY_DIR}/${parsed_WORKING_DIRECTORY}
      )
    endif()
  endif()
endmacro()

function(bison)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "NO_DEFAULT_OPTIONS;CODEGEN;VERBOSE;HEADER" # options
    "HEADER_FILE;WORKING_DIRECTORY;REPORT_FILE" # one-value keywords
    "OPTIONS;DEPENDS" # multi-value keywords
  )

  _bison_process(${ARGN})

  if(NOT CMAKE_SCRIPT_MODE_FILE)
    add_custom_target(${ARGV0} SOURCES ${input} DEPENDS ${outputs})
  endif()

  # Skip generation, if generated files are provided by the release archive.
  get_property(type GLOBAL PROPERTY _CMAKE_BISON_TYPE)
  if(NOT BISON_FOUND AND NOT BISON_FIND_REQUIRED AND NOT type STREQUAL "REQUIRED")
    return()
  endif()

  if(CMAKE_SCRIPT_MODE_FILE)
    message(STATUS "[BISON] ${message}")
    execute_process(${commands} WORKING_DIRECTORY ${parsed_WORKING_DIRECTORY})
    return()
  endif()

  set(codegen "")
  if(
    parsed_CODEGEN
    AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.31
    AND POLICY CMP0171
  )
    cmake_policy(GET CMP0171 cmp0171)

    if(cmp0171 STREQUAL "NEW")
      set(codegen CODEGEN)
    endif()
  endif()

  add_custom_command(
    OUTPUT ${outputs}
    ${commands}
    DEPENDS ${input} ${parsed_DEPENDS} $<TARGET_NAME_IF_EXISTS:Bison::Bison>
    COMMENT "[BISON][${ARGV0}] ${message}"
    VERBATIM
    COMMAND_EXPAND_LISTS
    ${codegen}
    WORKING_DIRECTORY ${parsed_WORKING_DIRECTORY}
  )
endfunction()

################################################################################
# Package definition.
################################################################################

block()
  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_SOURCE_DIR
    BASE_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE relativeDir
  )

  if(relativeDir STREQUAL ".")
    set(purpose "Necessary to generate parser files.")
  else()
    set(purpose "Necessary to generate ${relativeDir} parser files.")
  endif()

  set_package_properties(
    BISON
    PROPERTIES
      URL "https://www.gnu.org/software/bison/"
      DESCRIPTION "General-purpose parser generator"
      PURPOSE "${purpose}"
  )
endblock()

################################################################################
# Find the executable.
################################################################################

find_program(
  BISON_EXECUTABLE
  NAMES bison
  DOC "The bison executable path"
)
mark_as_advanced(BISON_EXECUTABLE)

################################################################################
# Version.
################################################################################

block(PROPAGATE BISON_VERSION _bisonVersionValid)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
    set(test IS_EXECUTABLE)
  else()
    set(test EXISTS)
  endif()

  if(${test} ${BISON_EXECUTABLE})
    execute_process(
      COMMAND ${BISON_EXECUTABLE} --version
      OUTPUT_VARIABLE versionOutput
      ERROR_VARIABLE error
      RESULT_VARIABLE result
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
      message(
        SEND_ERROR
        "Command \"${BISON_EXECUTABLE} --version\" failed with output:\n"
        "${error}"
      )
    elseif(versionOutput)
      # Bison++
      if(vesionOutput MATCHES "^bison\\+\\+ Version ([^,]+)")
        set(BISON_VERSION "${CMAKE_MATCH_1}")
      # GNU Bison
      elseif(versionOutput MATCHES "^bison \\(GNU Bison\\) ([^\n]+)\n")
        set(BISON_VERSION "${CMAKE_MATCH_1}")
      elseif(versionOutput MATCHES "^GNU Bison (version )?([^\n]+)")
        set(BISON_VERSION "${CMAKE_MATCH_2}")
      endif()

      find_package_check_version("${BISON_VERSION}" _bisonVersionValid)
    endif()
  endif()
endblock()

set(_bisonRequiredVars "")

################################################################################
# Download and build the package.
################################################################################

if(
  NOT CMAKE_SCRIPT_MODE_FILE
  AND NOT BISON_DISABLE_DOWNLOAD
  AND (NOT BISON_EXECUTABLE OR NOT _bisonVersionValid)
)
  # Set which bison version to download.
  if(NOT BISON_DOWNLOAD_VERSION)
    set(BISON_DOWNLOAD_VERSION 3.8.2)
  endif()
  set(BISON_VERSION ${BISON_DOWNLOAD_VERSION})

  if(NOT TARGET Bison::Bison)
    include(ExternalProject)

    # Configure bison build.
    set(_bisonDownloadOptions "")

    ExternalProject_Add(
      bison
      URL
        # :( https://github.com/.../.../archive/refs/tags/${BISON_VERSION}.tar.gz
      CMAKE_ARGS
        -DBISON_TODO=OFF
        ${_bisonDownloadOptions}
      INSTALL_COMMAND ""
    )

    # Set bison executable.
    ExternalProject_Get_property(bison BINARY_DIR)
    add_executable(Bison::Bison IMPORTED)
    set_target_properties(
      Bison::Bison
      PROPERTIES IMPORTED_LOCATION ${BINARY_DIR}/bison
    )
    add_dependencies(Bison::Bison bison)
    set_property(CACHE BISON_EXECUTABLE PROPERTY VALUE ${BINARY_DIR}/bison)
    unset(BINARY_DIR)
  endif()

  set(_bisonRequiredVars _bisonMsg)
  set(_bisonMsg "downloading at build")
endif()

find_package_handle_standard_args(
  BISON
  REQUIRED_VARS ${_bisonRequiredVars} BISON_EXECUTABLE BISON_VERSION
  VERSION_VAR BISON_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "bison not found. Please install bison."
)

unset(_bisonDownloadOptions)
unset(_bisonMsg)
unset(_bisonRequiredVars)
unset(_bisonVersionValid)
