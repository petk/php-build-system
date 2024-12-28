#[=============================================================================[
# FindRE2C

Find `re2c` command-line lexer generator.

When `re2c` cannot be found on the system or the found version is not suitable,
this module can also download and build it from its Git repository sources
release archive as part of the project build using the `ExternalProject` CMake
module.

## Result variables

* `RE2C_FOUND` - Whether the `re2c` was found.
* `RE2C_VERSION` - The `re2c` version.

## Cache variables

* `RE2C_EXECUTABLE` - Path to the `re2c`. When `re2c` is downloaded and built
  from source, this path is autofilled to point to the built `re2c` executable.
  Note, that the `re2c` executable built from source will not exist until the
  build phase.

## Hints

These variables can be set before calling the `find_package(RE2C)`:

* `RE2C_DEFAULT_OPTIONS` - A semicolon-separated list of default global re2c
  options to be prepended to `re2c(OPTIONS)` argument for all re2c invocations
  when generating lexer files.

* `RE2C_DISABLE_DOWNLOAD` - Set to `TRUE` to disable downloading and building
  RE2C package from source, when it is not found on the system or found version
  is not suitable.

* `RE2C_DOWNLOAD_VERSION` - Override the default `re2c` version to be downloaded
  when not found on the system.

* `RE2C_USE_COMPUTED_GOTOS` - Set to `TRUE` to enable the re2c
  `--computed-gotos` (`-g`) option if the non-standard C `computed goto`
  extension is supported by the C compiler. When using it in command-line script
  mode, option is not checked, whether the compiler supports it and is added to
  `re2c` options unconditionally.

## Functions provided by this module

### `re2c()`

Generate lexer file `<output>` from the given `<input>` template file using the
`re2c` lexer generator.

```cmake
re2c(
  <name>
  <input>
  <output>
  [HEADER <header>]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [NO_DEFAULT_OPTIONS]
  [NO_COMPUTED_GOTOS]
  [CODEGEN]
  [WORKING_DIRECTORY <working-directory>]
)
```

This creates a custom CMake target `<name>` and adds a custom command that
generates lexer file `<output>` from the given `<input>` template file using the
`re2c` lexer generator. Relative source file path `<input>` is interpreted as
being relative to the current source directory. Relative `<output>` file path is
interpreted as being relative to the current binary directory. If `re2c` is not
a required package and it is not found, it will create a custom target but skip
the `re2c` command execution.

When used in CMake command-line script mode (see `CMAKE_SCRIPT_MODE_FILE`) it
simply generates the lexer without creating a target, to make it easier to use
in various scenarios.

#### Options

* `HEADER <header>` - Generate a given `<header>` file. Relative header file
  path is interpreted as being relative to the current binary directory.

* `OPTIONS <options>...` - Optional list of additional options to pass to the
  re2c command-line tool.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `NO_DEFAULT_OPTIONS` - If specified, the `RE2C_DEFAULT_OPTIONS` are not added
  to the current `re2c` invocation.

* `NO_COMPUTED_GOTOS` - If specified, when using the `RE2C_USE_COMPUTED_GOTOS`,
  the computed gotos option is not added to the current `re2c` invocation.

* `CODEGEN` - Adds the `CODEGEN` option to the re2c's `add_custom_command()`
  call. Works as of CMake 3.31 when policy `CMP0171` is set to `NEW`, which
  provides a global CMake `codegen` target for convenience to call only the
  code-generation-related targets and skips the majority of the build:

  ```sh
  cmake --build <dir> --target codegen
  ```

* `WORKING_DIRECTORY <working-directory>` - The path where the `re2c` command is
  executed. By default, `re2c` is executed in the current binary directory
  (`CMAKE_CURRENT_BINARY_DIR`). Relative `<working-directory>` path is
  interpreted as being relative to the current binary directory.

## Examples

### Minimum re2c version

The minimum required `re2c` version can be specified using the standard CMake
syntax, e.g.

```cmake
# CMakeLists.txt

find_package(RE2C 1.0.3)
```

### Running re2c

```cmake
# CMakeLists.txt

find_package(RE2C)

# Commands provided by find modules must be called conditionally, because user
# can also disable the find module with CMAKE_DISABLE_FIND_PACKAGE_RE2C.
if(RE2C_FOUND)
  re2c(...)
endif()
```

### Specifying options

Setting default options for all `re2c()` calls in the scope of the
`find_package(RE2C)`:

```cmake
# CMakeLists.txt

# Optionally, set default options for all re2c invocations. For example, add
# option to suppress date output in the generated file:
set(RE2C_DEFAULT_OPTIONS --no-generation-date)

find_package(RE2C)

# This will execute re2c as:
# re2c --no-generation-date --bit-vectors --conditions --output foo.c foo.re
if(RE2C_FOUND)
  re2c(foo foo.re foo.c OPTIONS --bit-vectors --conditions)
endif()

# This will execute re2c as:
# re2c --no-generation-date --case-inverted --output bar.c bar.re
if(RE2C_FOUND)
  re2c(bar bar.re bar.c OPTIONS --case-inverted)
endif()
```

Generator expressions are supported in `re2c(OPTIONS)` when using it in the
`project()` mode:

```cmake
# CMakeLists.txt

find_package(RE2C)

if(RE2C_FOUND)
  re2c(foo foo.re foo.c OPTIONS $<$<CONFIG:Debug>:--debug-output>)
endif()
```

### Custom target usage

To specify dependencies with the custom target created by `re2c()`:

```cmake
# CMakeLists.txt

find_package(RE2C)

if(RE2C_FOUND)
  re2c(foo_lexer lexer.re lexer.c)
  add_dependencies(some_target foo_lexer)
endif()
```

Or to run only the specific `foo_lexer` target, which generates the lexer.

```sh
cmake --build <dir> --target foo_lexer
```

### Script mode

When running `re2c()` in script mode:

```sh
cmake -P script.cmake
```

the generated file is created right away:

```cmake
# script.cmake

find_package(RE2C REQUIRED)

if(RE2C_FOUND)
  re2c(lexer.re lexer.c)
endif()
```
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

################################################################################
# Functions.
################################################################################

# Process options.
function(_re2c_process_options options result)
  set(options ${${options}})

  if(
    RE2C_USE_COMPUTED_GOTOS
    AND _RE2C_HAVE_COMPUTED_GOTOS
    AND NOT parsed_NO_COMPUTED_GOTOS
  )
    list(PREPEND options "--computed-gotos")
  endif()

  if(RE2C_DEFAULT_OPTIONS AND NOT parsed_NO_DEFAULT_OPTIONS)
    list(PREPEND options ${RE2C_DEFAULT_OPTIONS})
  endif()

  set(${result} ${options})

  return(PROPAGATE ${result})
endfunction()

macro(_re2c_process)
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

  _re2c_process_options(parsed_OPTIONS options)

  if(parsed_HEADER)
    set(header ${parsed_HEADER})
    if(NOT IS_ABSOLUTE "${header}")
      set(header ${CMAKE_CURRENT_BINARY_DIR}/${header})
    endif()

    list(APPEND outputs ${header})

    # When header option is used before re2c version 1.2, also the '-c' option
    # is required. Before 1.1 '-c' long variant is '--start-conditions' and
    # after 1.1 '--conditions'.
    if(RE2C_VERSION VERSION_LESS_EQUAL 1.2)
      list(APPEND options -c)
    endif()

    # Since re2c version 3.0, '--header' is the new alias option for the
    # '--type-header' option.
    if(RE2C_VERSION VERSION_GREATER_EQUAL 3.0)
      list(APPEND options --header ${header})
    else()
      list(APPEND options --type-header ${header})
    endif()
  endif()

  # Assemble commands for add_custom_command() and execute_process().
  set(commands "")

  # RE2C cannot create output directories. Ensure any required directories for
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
    COMMAND ${RE2C_EXECUTABLE} ${options} --output ${output} ${input}
  )

  # Assemble status message.
  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE outputRelative
  )

  set(message "Generating ${outputRelative} with re2c ${RE2C_VERSION}")

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

function(re2c)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "NO_DEFAULT_OPTIONS;NO_COMPUTED_GOTOS;CODEGEN" # options
    "HEADER;WORKING_DIRECTORY" # one-value keywords
    "OPTIONS;DEPENDS" # multi-value keywords
  )

  _re2c_process(${ARGN})

  if(NOT CMAKE_SCRIPT_MODE_FILE)
    add_custom_target(${ARGV0} SOURCES ${input} DEPENDS ${outputs})
  endif()

  # Skip generation, if generated files are provided by the release archive.
  get_property(type GLOBAL PROPERTY _CMAKE_RE2C_TYPE)
  if(NOT RE2C_FOUND AND NOT RE2C_FIND_REQUIRED AND NOT type STREQUAL "REQUIRED")
    return()
  endif()

  if(CMAKE_SCRIPT_MODE_FILE)
    message(STATUS "[RE2C] ${message}")
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
    DEPENDS ${input} ${parsed_DEPENDS} $<TARGET_NAME_IF_EXISTS:RE2C::RE2C>
    COMMENT "[RE2C][${ARGV0}] ${message}"
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
    set(purpose "Necessary to generate lexer files.")
  else()
    set(purpose "Necessary to generate ${relativeDir} lexer files.")
  endif()

  set_package_properties(
    RE2C
    PROPERTIES
      URL "https://re2c.org/"
      DESCRIPTION "Lexer generator"
      PURPOSE "${purpose}"
  )
endblock()

################################################################################
# Find the package.
################################################################################

find_program(
  RE2C_EXECUTABLE
  NAMES re2c
  DOC "The re2c executable path"
)
mark_as_advanced(RE2C_EXECUTABLE)

block(PROPAGATE RE2C_VERSION _re2cVersionValid)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
    set(test IS_EXECUTABLE)
  else()
    set(test EXISTS)
  endif()

  if(${test} ${RE2C_EXECUTABLE})
    execute_process(
      COMMAND ${RE2C_EXECUTABLE} --vernum
      OUTPUT_VARIABLE versionNumber
      ERROR_VARIABLE error
      RESULT_VARIABLE result
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
      message(
        SEND_ERROR
        "Command \"${RE2C_EXECUTABLE} --vernum\" failed with output:\n"
        "${error}"
      )
    elseif(versionNumber)
      math(EXPR major "${versionNumber} / 10000")

      math(EXPR minor "(${versionNumber} - ${major} * 10000) / 100")

      math(EXPR patch "${versionNumber} - ${major} * 10000 - ${minor} * 100")

      set(RE2C_VERSION "${major}.${minor}.${patch}")

      find_package_check_version("${RE2C_VERSION}" _re2cVersionValid)
    endif()
  endif()
endblock()

set(_re2cRequiredVars "")

################################################################################
# Download and build the package.
################################################################################

if(
  NOT CMAKE_SCRIPT_MODE_FILE
  AND NOT RE2C_DISABLE_DOWNLOAD
  AND (NOT RE2C_EXECUTABLE OR NOT _re2cVersionValid)
)
  # Set which re2c version to download.
  if(NOT RE2C_DOWNLOAD_VERSION)
    set(RE2C_DOWNLOAD_VERSION 4.0.2)
  endif()
  set(RE2C_VERSION ${RE2C_DOWNLOAD_VERSION})

  if(NOT TARGET RE2C::RE2C)
    include(ExternalProject)

    # Configure re2c build.
    if(RE2C_VERSION VERSION_GREATER_EQUAL 4)
      set(
        _re2cDownloadOptions
        -DRE2C_BUILD_RE2D=OFF
        -DRE2C_BUILD_RE2HS=OFF
        -DRE2C_BUILD_RE2JAVA=OFF
        -DRE2C_BUILD_RE2JS=OFF
        -DRE2C_BUILD_RE2OCAML=OFF
        -DRE2C_BUILD_RE2PY=OFF
        -DRE2C_BUILD_RE2V=OFF
        -DRE2C_BUILD_RE2ZIG=OFF
        -DRE2C_BUILD_TESTS=OFF
      )
    else()
      set(
        _re2cDownloadOptions
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=TRUE
        -DPython3_VERSION=3.7
      )
    endif()

    ExternalProject_Add(
      re2c
      URL
        https://github.com/skvadrik/re2c/archive/refs/tags/${RE2C_VERSION}.tar.gz
      CMAKE_ARGS
        -DRE2C_BUILD_RE2GO=OFF
        -DRE2C_BUILD_RE2RUST=OFF
        ${_re2cDownloadOptions}
      INSTALL_COMMAND ""
    )

    # Set re2c executable.
    ExternalProject_Get_property(re2c BINARY_DIR)
    add_executable(RE2C::RE2C IMPORTED)
    set_target_properties(
      RE2C::RE2C
      PROPERTIES IMPORTED_LOCATION ${BINARY_DIR}/re2c
    )
    add_dependencies(RE2C::RE2C re2c)
    set_property(CACHE RE2C_EXECUTABLE PROPERTY VALUE ${BINARY_DIR}/re2c)
    unset(BINARY_DIR)
  endif()

  set(_re2cRequiredVars _re2cMsg)
  set(_re2cMsg "downloading at build")
endif()

find_package_handle_standard_args(
  RE2C
  REQUIRED_VARS ${_re2cRequiredVars} RE2C_EXECUTABLE RE2C_VERSION
  VERSION_VAR RE2C_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "re2c not found. Please install re2c."
)

unset(_re2cDownloadOptions)
unset(_re2cMsg)
unset(_re2cRequiredVars)
unset(_re2cVersionValid)

if(NOT RE2C_FOUND)
  return()
endif()

# Check for re2c --computed-gotos option.
if(NOT CMAKE_SCRIPT_MODE_FILE AND RE2C_USE_COMPUTED_GOTOS)
  message(CHECK_START "Checking for re2c --computed-gotos (-g) option support")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
      int main(void)
      {
      label1:
        ;
      label2:
        ;
        static void *adr[] = { &&label1, &&label2 };
        goto *adr[0];
        return 0;
      }
    ]] _RE2C_HAVE_COMPUTED_GOTOS)
  cmake_pop_check_state()

  if(_RE2C_HAVE_COMPUTED_GOTOS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
elseif(CMAKE_SCRIPT_MODE_FILE AND RE2C_USE_COMPUTED_GOTOS)
  set(_RE2C_HAVE_COMPUTED_GOTOS TRUE)
endif()
