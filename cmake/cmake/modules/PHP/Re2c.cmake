#[=============================================================================[
# PHP/Re2c

Generate lexer files with re2c.

## Functions

### `php_re2c()`

Generate lexer file from the given template file using the re2c generator.

```cmake
php_re2c(
  <name>
  <input>
  <output>
  [HEADER <header>]
  [ADD_DEFAULT_OPTIONS]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [COMPUTED_GOTOS <TRUE|FALSE>]
  [CODEGEN]
  [WORKING_DIRECTORY <directory>]
  [ABSOLUTE_PATHS]
)
```

This creates a target `<name>` and adds a command that generates lexer file
`<output>` from the given `<input>` template file using the re2c lexer
generator. Relative source file path `<input>` is interpreted as being relative
to the current source directory. Relative `<output>` file path is interpreted as
being relative to the current binary directory. If generated files are already
available (for example, shipped with the released archive), and re2c is not
found, it will create a target but skip the `re2c` command-line execution.

When used in command-line script mode (see `CMAKE_SCRIPT_MODE_FILE`) it
generates the lexer right away without creating a target.

#### Options

* `HEADER <header>` - Generate a given `<header>` file. Relative header file
  path is interpreted as being relative to the current binary directory.

* `ADD_DEFAULT_OPTIONS` - When specified, the options from the
  `PHP_RE2C_OPTIONS` configuration variable are prepended to the current
  `re2c` command-line invocation. This module provides some sensible defaults.

* `OPTIONS <options>...` - List of additional options to pass to the `re2c`
  command-line tool. Supports generator expressions. In script mode
  (`CMAKE_SCRIPT_MODE_FILE`) generator expressions are stripped as they can't be
  determined.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `COMPUTED_GOTOS <TRUE|FALSE>` - Set to `TRUE` to add the `--computed-gotos`
  (`-g`) command-line option if the non-standard C computed goto extension is
  supported by the C compiler. When calling `re2c()` in the command-line script
  mode (`CMAKE_SCRIPT_MODE`), option is not checked, whether the compiler
  supports it and is added unconditionally.

* `CODEGEN` - Adds the `CODEGEN` option to the `add_custom_command()` call. This
  option is available starting with CMake 3.31 when the policy `CMP0171` is set
  to `NEW`. It provides a `codegen` target for convenience, allowing to run only
  code-generation-related targets while skipping the majority of the build:

  ```sh
  cmake --build <dir> --target codegen
  ```

* `WORKING_DIRECTORY <directory>` - The path where the `re2c` is executed.
  Relative `<directory>` path is interpreted as being relative to the current
  binary directory. If not set, `re2c` is by default executed in the
  `PHP_SOURCE_DIR` when building the php-src repository. Otherwise it is
  executed in the directory of the `<output>` file. If variable
  `PHP_RE2C_WORKING_DIRECTORY` is set before calling the `php_re2c()` without
  this option, it will set the default working directory to that instead.

* `ABSOLUTE_PATHS` - Whether to use absolute file paths in the `re2c`
  command-line invocations. By default all file paths are added as relative to
  the working directory. Using relative paths is convenient when line directives
  (`#line ...`) are generated in the output files committed to Git repository.

  When this option is enabled:

  ```c
  #line 108 "/home/user/php-src/ext/phar/phar_path_check.c"
  ```

  Without this option relative paths are generated:

  ```c
  #line 108 "ext/phar/phar_path_check.c"
  ```

## Configuration variables

These variables can be set before using this module to configure behavior:

* `PHP_RE2C_COMPUTED_GOTOS` - Add the `COMPUTED_GOTOS TRUE` option to all
  `php_re2c()` invocations in the directory scope.

* `PHP_RE2C_OPTIONS` - A semicolon-separated list of default re2c command-line
  options when `php_re2c(ADD_DEFAULT_OPTIONS)` is used.

* `PHP_RE2C_VERSION` - The version constraint, when looking for RE2C package
  with `find_package(RE2C <version-constraint> ...)` in this module.

* `PHP_RE2C_VERSION_DOWNLOAD` - When re2c cannot be found on the system or the
  found version is not suitable, this module can also download and build it from
  its release archive sources as part of the project build. Set which version
  should be downloaded.

* `PHP_RE2C_WORKING_DIRECTORY` - Set the default global working directory
  for all `php_re2c()` invocations in the directory scope where the
  `WORKING_DIRECTORY <directory>` option is not set.

## Examples

### Basic usage

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(foo foo.re foo.c OPTIONS --bit-vectors --conditions)
# This will run:
#   re2c --bit-vectors --conditions --output foo.c foo.re
```

### Specifying options

This module provides some default options when using the `ADD_DEFAULT_OPTIONS`:

```cmake
include(PHP/Re2c)

php_re2c(foo foo.re foo.c ADD_DEFAULT_OPTIONS OPTIONS --conditions)
# This will run:
#   re2c --no-debug-info --no-generation-date --conditions --output foo.c foo.re
```

### Generator expressions

```cmake
include(PHP/Re2c)

php_re2c(foo foo.re foo.c OPTIONS $<$<CONFIG:Debug>:--debug-output> -F)
# When build type is Debug, this will run:
#   re2c --debug-output -F --output foo.c foo.re
# For other build types (including the script mode - CMAKE_SCRIPT_MODE_FILE):
#   re2c -F --output foo.c foo.re
```

### Target usage

Target created by `php_re2c()` can be used to specify additional dependencies:

```cmake
# CMakeLists.txt

include(PHP/Re2c)

php_re2c(foo_lexer lexer.re lexer.c)
add_dependencies(some_target foo_lexer)
```

Running only the `foo_lexer` target to generate the lexer-related files:

```sh
cmake --build <dir> --target foo_lexer
```

### Module configuration

To specify different minimum required re2c version than the module's default,
the `find_package(RE2C)` can be called before `php_re2c()`:

```cmake
include(PHP/Re2c)
find_package(RE2C 3.1)
php_re2c(...)
```
#]=============================================================================]

################################################################################
# Configuration.
################################################################################

macro(_php_re2c_config)
  # Minimum required re2c version.
  if(NOT PHP_RE2C_VERSION)
    set(PHP_RE2C_VERSION 1.0.3)
  endif()

  # If re2c is not found on the system, set which version to download.
  if(NOT PHP_RE2C_VERSION_DOWNLOAD)
    set(PHP_RE2C_VERSION_DOWNLOAD 4.0.2)
  endif()
endmacro()

_php_re2c_config()

include_guard(GLOBAL)

include(FeatureSummary)

option(PHP_RE2C_COMPUTED_GOTOS "Enable computed goto GCC extension with re2c")
mark_as_advanced(PHP_RE2C_COMPUTED_GOTOS)

# Configuration after find_package() in this module.
macro(_php_re2c_config_options)
  if(NOT PHP_RE2C_OPTIONS)
    # Add --no-debug-info (-i) option to not output '#line' directives.
    if(CMAKE_SCRIPT_MODE_FILE)
      set(PHP_RE2C_OPTIONS --no-debug-info)
    else()
      set(PHP_RE2C_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-debug-info>)
    endif()

    # Suppress date output in the generated file.
    list(APPEND PHP_RE2C_OPTIONS --no-generation-date)

    # TODO: https://github.com/php/php-src/issues/17204
    if(RE2C_VERSION VERSION_GREATER_EQUAL 4)
      list(
        APPEND
        PHP_RE2C_OPTIONS
        -Wno-unreachable-rules
        -Wno-condition-order
        -Wno-undefined-control-flow
      )
    endif()
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
    "ADD_DEFAULT_OPTIONS;CODEGEN;ABSOLUTE_PATHS" # options
    "HEADER;WORKING_DIRECTORY;COMPUTED_GOTOS" # one-value keywords
    "OPTIONS;DEPENDS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  cmake_path(
    ABSOLUTE_PATH
    input
    BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    NORMALIZE
  )

  cmake_path(
    ABSOLUTE_PATH
    output
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    NORMALIZE
  )

  set(outputs ${output})

  if(parsed_HEADER)
    cmake_path(
      ABSOLUTE_PATH
      parsed_HEADER
      BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      NORMALIZE
    )
    list(APPEND outputs ${parsed_HEADER})
  endif()

  _php_re2c_set_package_properties()

  get_property(packageType GLOBAL PROPERTY _CMAKE_RE2C_TYPE)
  set(quiet "")
  if(NOT packageType STREQUAL "REQUIRED")
    set(quiet "QUIET")
  endif()

  _php_re2c_config()

  # Skip consecutive calls if downloading or outer find_package() was called.
  if(NOT TARGET RE2C::RE2C AND NOT DEFINED RE2C_FOUND)
    find_package(RE2C ${PHP_RE2C_VERSION} ${quiet})
  endif()

  if(
    NOT RE2C_FOUND
    AND PHP_RE2C_VERSION_DOWNLOAD
    AND packageType STREQUAL "REQUIRED"
    AND NOT CMAKE_SCRIPT_MODE_FILE
  )
    _php_re2c_download()
  endif()

  # Set working directory.
  if(NOT parsed_WORKING_DIRECTORY)
    if(PHP_RE2C_WORKING_DIRECTORY)
      set(parsed_WORKING_DIRECTORY ${PHP_RE2C_WORKING_DIRECTORY})
    elseif(PHP_HOMEPAGE_URL AND PHP_SOURCE_DIR)
      # Building php-src.
      set(parsed_WORKING_DIRECTORY ${PHP_SOURCE_DIR})
    else()
      # Otherwise set working directory to the directory of the output file.
      cmake_path(GET output PARENT_PATH parsed_WORKING_DIRECTORY)
    endif()
  endif()
  cmake_path(
    ABSOLUTE_PATH
    parsed_WORKING_DIRECTORY
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    NORMALIZE
  )

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
    OUTPUT_VARIABLE relativePath
  )
  set(message "[re2c] Generating ${relativePath} with re2c ${RE2C_VERSION}")

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

# Process options.
function(_php_re2c_process_options)
  _php_re2c_config_options()

  set(options ${parsed_OPTIONS})

  if(PHP_RE2C_COMPUTED_GOTOS OR parsed_COMPUTED_GOTOS)
    _php_re2c_check_computed_gotos(result)
    if(result)
      list(PREPEND options --computed-gotos)
    endif()
  endif()

  if(PHP_RE2C_OPTIONS AND parsed_ADD_DEFAULT_OPTIONS)
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

  if(parsed_ABSOLUTE_PATHS)
    set(headerArgument "${parsed_HEADER}")
  else()
    cmake_path(
      RELATIVE_PATH
      parsed_HEADER
      BASE_DIRECTORY ${parsed_WORKING_DIRECTORY}
      OUTPUT_VARIABLE headerArgument
    )
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
    list(APPEND options --header ${headerArgument})
  else()
    list(APPEND options --type-header ${headerArgument})
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
  set(RE2C_VERSION ${PHP_RE2C_VERSION_DOWNLOAD})
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
