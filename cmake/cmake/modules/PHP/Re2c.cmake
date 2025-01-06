#[=============================================================================[
# PHP/Re2c

Generate lexer-related files with re2c. This module includes common `re2c`
configuration with minimum required version and common settings across the
PHP build.

## Configuration variables

These variables can be set before including this module
`include(PHP/Re2c)`:

* `PHP_RE2C_VERSION` - The re2c version constraint, when looking for RE2C
  package with `find_package(RE2C <version-constraint> ...)`.

* `PHP_RE2C_DOWNLOAD_VERSION` - When re2c cannot be found on the system or the
  found version is not suitable, this module can also download and build it from
  its release archive sources as part of the project build. Set which re2c
  version should be downloaded.

* `PHP_RE2C_COMPUTED_GOTOS` - Add the `COMPUTED_GOTOS TRUE` option to all
  `php_re2c()` invocations in the scope of current directory.

* `PHP_RE2C_OPTIONS` - A semicolon-separated list of default re2c options.
  This module sets some sensible defaults. When `php_re2c(APPEND)` is used, the
  options specified in the `php_re2c(OPTIONS <options>...)` are appended to
  these default global options.

* `PHP_RE2C_WORKING_DIRECTORY` - Set the default global working directory
  (`WORKING_DIRECTORY <dir>` option) for all `php_re2c()` invocations in the
  scope of the current directory.

## Functions provided by this module

### `php_re2c()`

Generate lexer file from the given template file using the `re2c` lexer
generator.

```cmake
php_re2c(
  <name>
  <input>
  <output>
  [HEADER <header>]
  [APPEND]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [COMPUTED_GOTOS <TRUE|FALSE>]
  [CODEGEN]
  [WORKING_DIRECTORY <working-directory>]
  [ABSOLUTE_PATHS]
)
```

This creates a custom CMake target `<name>` and adds a custom command that
generates lexer file `<output>` from the given `<input>` template file using the
`re2c` lexer generator. Relative source file path `<input>` is interpreted as
being relative to the current source directory. Relative `<output>` file path is
interpreted as being relative to the current binary directory. If generated
files are already available (for example, shipped with the released archive),
and re2c is not found, it will create a custom target but skip the `re2c`
command-line execution.

When used in CMake command-line script mode (see `CMAKE_SCRIPT_MODE_FILE`) it
generates the lexer without creating a target, to make it easier to use in
various scenarios.

#### Options

* `HEADER <header>` - Generate a given `<header>` file. Relative header file
  path is interpreted as being relative to the current binary directory.

* `APPEND` - If specified, the `PHP_RE2C_OPTIONS` are prepended to
  `OPTIONS <options...>` for the current `re2c` invocation.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `COMPUTED_GOTOS <TRUE|FALSE>` - Set to `TRUE` to add the re2c
  `--computed-gotos` (`-g`) command-line option if the non-standard C computed
  goto extension is supported by the C compiler. When calling `re2c()` in the
  command-line script mode (`CMAKE_SCRIPT_MODE`), option is not checked, whether
  the compiler supports it and is added to `re2c` command-line options
  unconditionally.

* `CODEGEN` - Adds the `CODEGEN` option to the re2c's `add_custom_command()`
  call. Works as of CMake 3.31 when policy `CMP0171` is set to `NEW`, which
  provides a global CMake `codegen` target for convenience to call only the
  code-generation-related targets and skips the majority of the build:

  ```sh
  cmake --build <dir> --target codegen
  ```

* `WORKING_DIRECTORY <working-directory>` - The path where the `re2c` command is
  executed. Relative `<working-directory>` path is interpreted as being relative
  to the current binary directory. If not set, `re2c` is by default executed in
  the current binary directory (`CMAKE_CURRENT_BINARY_DIR`). If variable
  `PHP_RE2C_WORKING_DIRECTORY` is set before calling the `php_re2c()` without
  this option, it will set the default working directory to that.

* `ABSOLUTE_PATHS` - Whether to use absolute file paths in the `re2c`
  command-line invocations. By default all file paths are added to `re2c`
  command-line relative to the working directory. Using relative paths is
  convenient when line directives (`#line ...`) are generated in the output
  lexer files to not show the full path on the disk, when file is committed to
  Git repository, where multiple people develop.

  When this option is enabled:

  ```c
  #line 108 "/home/user/projects/php-src/ext/phar/phar_path_check.c"
  ```

  Without this option, relative paths will be generated:

  ```c
  #line 108 "ext/phar/phar_path_check.c"
  ```

## Examples

### Basic usage

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(...)
```

### Minimum re2c version

To override the module default minimum required `re2c` version:

```cmake
# CMakeLists.txt

set(PHP_RE2C_VERSION 3.8.0)
include(PHP/Re2c)
```

### Specifying options

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(foo foo.re foo.c OPTIONS --bit-vectors --conditions)
# This will run:
#   re2c --bit-vectors --conditions --output foo.c foo.re
```

This module also provides some sensible default options, which can be prepended
to current specified options using the `APPEND` keyword.

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(foo foo.re foo.c APPEND OPTIONS --conditions)
# This will run:
#   re2c --no-debug-info --no-generation-date --conditions --output foo.c foo.re
```

Generator expressions are supported in `php_re2c(OPTIONS)` when running in
normal CMake `project()` mode:

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(foo foo.re foo.c OPTIONS $<$<CONFIG:Debug>:--debug-output> --conditions)
# When build type is Debug, this will run:
#   re2c --debug-output -conditions --output foo.c foo.re
# For other build types:
#   re2c --conditions --output foo.c foo.re
```

Setting default options for all `php_re2c()` calls in the current directory
scope:

```cmake
# CMakeLists.txt

set(PHP_RE2C_OPTIONS --no-generation-date)

include(PHP/Re2c)

php_re2c(foo foo.re foo.c APPEND OPTIONS --conditions)
# This will run:
#   re2c --no-generation-date --conditions --output foo.c foo.re
```

### Custom target usage

To specify dependencies with the custom target created by `re2c()`:

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(foo_lexer lexer.re lexer.c)
add_dependencies(some_target foo_lexer)
```

Or to run only the specific `foo_lexer` target, which generates the
lexer-related files.

```sh
cmake --build <dir> --target foo_lexer
```

### Script mode

When running `php_re2c()` in script mode (`CMAKE_SCRIPT_MODE_FILE`):

```sh
cmake -P script.cmake
```

the generated file is created right away, without creating target:

```cmake
# script.cmake

include(PHP/Re2c)

php_re2c(foo_lexer lexer.re lexer.c)
```

In script mode also all options with generator expressions are removed from the
invocation as they can't be parsed and determined in such mode.

```cmake
# script.cmake

include(PHP/Re2c)

php_re2c(foo lexer.y lexer.c OPTIONS $<$<CONFIG:Debug>:--debug-output> -F)
# This will run:
#   re2c -F --output lexer.c lexer.re
```
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

################################################################################
# Configuration.
################################################################################

option(PHP_RE2C_COMPUTED_GOTOS "Enable computed goto GCC extension with re2c")
mark_as_advanced(PHP_RE2C_COMPUTED_GOTOS)

macro(php_re2c_config)
  # Minimum required re2c version.
  if(NOT PHP_RE2C_VERSION)
    set(PHP_RE2C_VERSION 1.0.3)
  endif()

  # If re2c is not found on the system, set which version to download.
  if(NOT PHP_RE2C_DOWNLOAD_VERSION)
    set(PHP_RE2C_DOWNLOAD_VERSION 4.0.2)
  endif()

  if(NOT PHP_RE2C_OPTIONS)
    # Add --no-debug-info (-i) option to not output line directives.
    if(CMAKE_SCRIPT_MODE_FILE)
      set(PHP_RE2C_OPTIONS --no-debug-info)
    else()
      set(PHP_RE2C_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-debug-info>)
    endif()

    # Suppress date output in the generated file.
    list(APPEND PHP_RE2C_OPTIONS --no-generation-date)
  endif()

  # Set working directory for all re2c invocations.
  if(NOT PHP_RE2C_WORKING_DIRECTORY)
    if(PHP_SOURCE_DIR)
      set(PHP_RE2C_WORKING_DIRECTORY ${PHP_SOURCE_DIR})
    else()
      set(PHP_RE2C_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
  endif()

  # See: https://github.com/php/php-src/issues/17204
  # TODO: Remove this once fixed upstream.
  # TODO: Refactor this because the found re2c version is here not known yet.
  if(RE2C_VERSION VERSION_GREATER_EQUAL 4)
    list(
      APPEND
      PHP_RE2C_OPTIONS
      -Wno-unreachable-rules
      -Wno-condition-order
      -Wno-undefined-control-flow
    )
  endif()
endmacro()

################################################################################
# Functions.
################################################################################

function(php_re2c name input output)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "APPEND;CODEGEN;ABSOLUTE_PATHS" # options
    "HEADER;WORKING_DIRECTORY;COMPUTED_GOTOS" # one-value keywords
    "OPTIONS;DEPENDS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT IS_ABSOLUTE "${input}")
    cmake_path(
      ABSOLUTE_PATH
      input
      BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      NORMALIZE
    )
  else()
    cmake_path(SET input NORMALIZE "${input}")
  endif()

  if(NOT IS_ABSOLUTE "${output}")
    cmake_path(
      ABSOLUTE_PATH
      output
      BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      NORMALIZE
    )
  else()
    cmake_path(SET output NORMALIZE "${output}")
  endif()

  set(outputs ${output})

  php_re2c_config()
  _php_re2c_process_header_file()
  _php_re2c_set_package_properties()

  get_property(packageType GLOBAL PROPERTY _CMAKE_RE2C_TYPE)
  set(quiet "")
  if(NOT packageType STREQUAL "REQUIRED")
    set(quiet "QUIET")
  endif()

  if(NOT TARGET RE2C::RE2C)
    find_package(RE2C ${PHP_RE2C_VERSION} GLOBAL ${quiet})
  endif()

  if(
    NOT RE2C_FOUND
    AND PHP_RE2C_DOWNLOAD_VERSION
    AND packageType STREQUAL "REQUIRED"
    AND NOT CMAKE_SCRIPT_MODE_FILE
  )
    _php_re2c_download()
  endif()

  _php_re2c_process_working_directory()
  _php_re2c_process_options()
  _php_re2c_process_header_option()

  if(NOT CMAKE_SCRIPT_MODE_FILE)
    add_custom_target(${name} SOURCES ${input} DEPENDS ${outputs})
  endif()

  # Skip generation, if generated files are provided by the release archive.
  get_property(type GLOBAL PROPERTY _CMAKE_RE2C_TYPE)
  if(NOT RE2C_FOUND AND NOT type STREQUAL "REQUIRED")
    return()
  endif()

  _php_re2c_get_commands(commands)

  # Assemble status message.
  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE outputRelative
  )
  set(message "[re2c] Generating ${outputRelative} with re2c ${RE2C_VERSION}")

  if(CMAKE_SCRIPT_MODE_FILE)
    message(STATUS "${message}")
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
    DEPENDS
      ${input}
      ${parsed_DEPENDS}
      $<TARGET_NAME_IF_EXISTS:RE2C::RE2C>
    COMMENT "${message}"
    VERBATIM
    COMMAND_EXPAND_LISTS
    ${codegen}
    WORKING_DIRECTORY ${parsed_WORKING_DIRECTORY}
  )
endfunction()

# Process header file.
function(_php_re2c_process_header_file)
  if(NOT parsed_HEADER)
    return()
  endif()

  set(header ${parsed_HEADER})
  if(NOT IS_ABSOLUTE "${header}")
    cmake_path(
      ABSOLUTE_PATH
      header
      BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      NORMALIZE
    )
  else()
    cmake_path(SET header NORMALIZE "${header}")
  endif()

  list(APPEND outputs ${header})

  return(PROPAGATE header outputs)
endfunction()

# Set RE2C package properties TYPE and PURPOSE. If lexer-related output files
# are already generated, for example, shipped with the released archive, then
# RE2C package type is set to RECOMMENDED. If generated files are not
# available, for example, when building from a Git repository, type is set to
# REQUIRED to generate files during the build.
function(_php_re2c_set_package_properties)
  set_package_properties(RE2C PROPERTIES TYPE RECOMMENDED)
  foreach(output IN LISTS outputs)
    if(NOT EXISTS ${output})
      set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
      break()
    endif()
  endforeach()

  # Set package PURPOSE property.
  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE relativePath
  )
  if(relativePath STREQUAL ".")
    set(purpose "Necessary to generate lexer files.")
  else()
    set(purpose "Necessary to generate ${relativePath} lexer files.")
  endif()
  set_package_properties(RE2C PROPERTIES PURPOSE "${purpose}")
endfunction()

# Process working directory.
function(_php_re2c_process_working_directory)
  if(NOT parsed_WORKING_DIRECTORY)
    if(PHP_RE2C_WORKING_DIRECTORY)
      set(parsed_WORKING_DIRECTORY ${PHP_RE2C_WORKING_DIRECTORY})
    else()
      set(parsed_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    endif()
  endif()

  if(NOT IS_ABSOLUTE "${parsed_WORKING_DIRECTORY}")
    cmake_path(
      ABSOLUTE_PATH
      parsed_WORKING_DIRECTORY
      BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      NORMALIZE
    )
  else()
    cmake_path(
      SET
      parsed_WORKING_DIRECTORY
      NORMALIZE
      "${parsed_WORKING_DIRECTORY}"
    )
  endif()

  return(PROPAGATE parsed_WORKING_DIRECTORY)
endfunction()

# Process options.
function(_php_re2c_process_options)
  set(options ${parsed_OPTIONS})

  if(PHP_RE2C_COMPUTED_GOTOS OR parsed_COMPUTED_GOTOS)
    _php_re2c_check_computed_gotos(result)
    if(result)
      list(PREPEND options --computed-gotos)
    endif()
  endif()

  if(PHP_RE2C_OPTIONS AND parsed_APPEND)
    list(PREPEND options ${PHP_RE2C_OPTIONS})
  endif()

  # Remove any generator expressions when running in script mode.
  if(CMAKE_SCRIPT_MODE_FILE)
    list(TRANSFORM options GENEX_STRIP)
  endif()

  # Sync long -c variants. The long --conditions option was introduced in re2c
  # version 1.1 as a new alias for the legacy --start-conditions.
  if(RE2C_VERSION VERSION_LESS 1.1)
    list(TRANSFORM options REPLACE "^--conditions$" "--start-conditions")
  else()
    list(TRANSFORM options REPLACE "^--start-conditions$" "--conditions")
  endif()

  return(PROPAGATE options)
endfunction()

# Process HEADER option.
function(_php_re2c_process_header_option)
  if(NOT parsed_HEADER)
    return()
  endif()

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

  return(PROPAGATE options)
endfunction()

# Check for re2c --computed-gotos option.
function(_php_re2c_check_computed_gotos result)
  if(CMAKE_SCRIPT_MODE_FILE)
    set(${result} TRUE)
    return(PROPAGATE ${result})
  endif()

  if(DEFINED _PHP_RE2C_HAVE_COMPUTED_GOTOS)
    set(${result} ${_PHP_RE2C_HAVE_COMPUTED_GOTOS})
    return(PROPAGATE ${result})
  endif()

  include(CheckSourceCompiles)
  include(CMakePushCheckState)

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
    ]] _PHP_RE2C_HAVE_COMPUTED_GOTOS)
  cmake_pop_check_state()
  if(_PHP_RE2C_HAVE_COMPUTED_GOTOS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  set(${result} ${_PHP_RE2C_HAVE_COMPUTED_GOTOS})

  return(PROPAGATE ${result})
endfunction()

# Assemble commands for add_custom_command() and execute_process().
function(_php_re2c_get_commands result)
  set(${result} "")

  if(parsed_ABSOLUTE_PATHS)
    set(inputArgument "${input}")
    set(outputArgument "${output}")
  else()
    cmake_path(
      RELATIVE_PATH
      input
      BASE_DIRECTORY ${parsed_WORKING_DIRECTORY}
      OUTPUT_VARIABLE inputArgument
    )
    cmake_path(
      RELATIVE_PATH
      output
      BASE_DIRECTORY ${parsed_WORKING_DIRECTORY}
      OUTPUT_VARIABLE outputArgument
    )
  endif()

  # re2c cannot create output directories. Ensure any required directories for
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
      ${result}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${directories}
    )
  endif()

  list(
    APPEND
    ${result}
    COMMAND
    ${RE2C_EXECUTABLE}
    ${options}
    --output ${outputArgument}
    ${inputArgument}
  )

  return(PROPAGATE ${result})
endfunction()

# Download and build re2c if not found.
function(_php_re2c_download)
  set(RE2C_VERSION ${PHP_RE2C_DOWNLOAD_VERSION})
  set(RE2C_FOUND TRUE)

  if(TARGET RE2C::RE2C)
    return(PROPAGATE RE2C_FOUND RE2C_VERSION)
  endif()

  message(STATUS "Re2c ${RE2C_VERSION} will be downloaded at build phase")

  include(ExternalProject)

  # Configure re2c build.
  if(RE2C_VERSION VERSION_GREATER_EQUAL 4)
    set(
      re2cOptions
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
      re2cOptions
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
      ${re2cOptions}
    INSTALL_COMMAND ""
  )

  # Set re2c executable.
  ExternalProject_Get_Property(re2c BINARY_DIR)
  set_property(CACHE RE2C_EXECUTABLE PROPERTY VALUE ${BINARY_DIR}/re2c)

  add_executable(RE2C::RE2C IMPORTED GLOBAL)
  set_target_properties(
    RE2C::RE2C
    PROPERTIES IMPORTED_LOCATION ${RE2C_EXECUTABLE}
  )
  add_dependencies(RE2C::RE2C re2c)

  # Move dependency to PACKAGES_FOUND.
  get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
  list(REMOVE_ITEM packagesNotFound RE2C)
  set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
  get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
  set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND RE2C)

  return(PROPAGATE RE2C_FOUND RE2C_VERSION)
endfunction()
