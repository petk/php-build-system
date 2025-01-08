#[=============================================================================[
# PHP/Bison

Generate parser files with Bison.

## Functions

### `php_bison()`

Generate parser file from the given template file using the Bison generator.

```cmake
php_bison(
  <name>
  <input>
  <output>
  [HEADER | HEADER_FILE <header>]
  [ADD_DEFAULT_OPTIONS]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [VERBOSE [REPORT_FILE <file>]]
  [CODEGEN]
  [WORKING_DIRECTORY <working-directory>]
  [ABSOLUTE_PATHS]
)
```

This creates a CMake target `<name>` and adds a command that generates parser
file `<output>` from the given `<input>` template file using the `bison` parser
generator. Relative source file path `<input>` is interpreted as being relative
to the current source directory. Relative `<output>` file path is interpreted as
being relative to the current binary directory. If generated files are already
available (for example, shipped with the released archive), and Bison is not
found, it will create a custom target but skip the `bison` command-line
execution.

When used in CMake command-line script mode (see `CMAKE_SCRIPT_MODE_FILE`) it
generates the parser right away without creating a target.

#### Options

* `HEADER` - Generate also a header file automatically.

* `HEADER_FILE <header>` - Generate a specified header file `<header>`. Relative
  header file path is interpreted as being relative to the current binary
  directory.

* `ADD_DEFAULT_OPTIONS` - When specified, the options from the
  `PHP_BISON_OPTIONS` configuration variable are prepended to the current
  `bison` command-line invocation. This module provides some sensible defaults.

* `OPTIONS <options>...` - List of additional options to pass to the `bison`
  command-line tool. Supports generator expressions. In script mode
  (`CMAKE_SCRIPT_MODE_FILE`) generator expressions are stripped as they can't be
  determined.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `VERBOSE` - This adds the `--verbose` (`-v`) command-line option to and will
  create extra output file `<parser-output-filename>.output` containing verbose
  descriptions of the grammar and parser. File will be by default created in the
  current binary directory.

* `REPORT_FILE <file>` - This adds the `--report-file=<file>` command-line
  option and will create verbose information report in the specified `<file>`.
  This option must be used together with the `VERBOSE` option. Relative file
  path is interpreted as being relative to the current binary directory.

* `CODEGEN` - This adds the `CODEGEN` option to the `add_custom_command()` call.
  Works as of CMake 3.31 when policy `CMP0171` is set to `NEW`, which provides a
  global CMake `codegen` target for convenience to call only the
  code-generation-related targets and skip the majority of the build:

  ```sh
  cmake --build <dir> --target codegen
  ```

* `WORKING_DIRECTORY <working-directory>` - The path where the `bison` is
  executed. Relative `<working-directory>` path is interpreted as being relative
  to the current binary directory. If not set, `bison` is by default executed in
  the `PHP_SOURCE_DIR` when building the php-src repository. Otherwise it is
  executed in the directory of the `<output>` file. If variable
  `PHP_BISON_WORKING_DIRECTORY` is set before calling the `php_bison()` without
  this option, it will set the default working directory to that instead.

* `ABSOLUTE_PATHS` - Whether to use absolute file paths in the `bison`
  command-line invocations. By default all file paths are added to `bison` as
  relative to the working directory. Using relative paths is convenient when
  line directives (`#line ...`) are generated in the output files to not show
  the full path on the disk, if file is committed to Git repository.

  When this option is enabled:

  ```c
  #line 15 "/home/user/php-src/sapi/phpdbg/phpdbg_parser.y"
  ```

  Without this option relative paths are generated:

  ```c
  #line 15 "sapi/phpdbg/phpdbg_parser.y"
  ```

## Configuration variables

These variables can be set before using this module to configure behavior:

* `PHP_BISON_OPTIONS` - A semicolon-separated list of default Bison command-line
  options when `php_bison(ADD_DEFAULT_OPTIONS)` is used.

* `PHP_BISON_VERSION` - The version constraint, when looking for BISON package
  with `find_package(BISON <version-constraint> ...)` in this module.

* `PHP_BISON_VERSION_DOWNLOAD` - When Bison cannot be found on the system or the
  found version is not suitable, this module can also download and build it from
  its release archive sources as part of the project build. Set which version
  should be downloaded.

* `PHP_BISON_WORKING_DIRECTORY` - Set the default global working directory
  for all `php_bison()` invocations in the directory scope where the
  `WORKING_DIRECTORY <dir>` option is not set.

## Examples

### Basic usage

```cmake
# CMakeLists.txt

include(PHP/Bison)

php_bison(foo foo.y foo.c OPTIONS -Wall --debug)
# This will run:
#   bison -Wall --debug foo.y --output foo.c
```

### Specifying options

This module provides some default options when using the `ADD_DEFAULT_OPTIONS`:

```cmake
include(PHP/Bison)

php_bison(foo foo.y foo.c ADD_DEFAULT_OPTIONS OPTIONS --debug --yacc)
# This will run:
#   bison -Wall --no-lines --debug --yacc foo.y --output foo.c
```

### Generator expressions

```cmake
include(PHP/Bison)

php_bison(foo foo.y foo.c OPTIONS $<$<CONFIG:Debug>:--debug> --yacc)
# When build type is Debug, this will run:
#   bison --debug --yacc foo.y --output foo.c
# For other build types (including the script mode - CMAKE_SCRIPT_MODE_FILE):
#   bison --yacc foo.y --output foo.c
```

### Custom target usage

To specify dependencies with the custom target created by `php_bison()`:

```cmake
# CMakeLists.txt

include(PHP/Bison)

php_bison(foo_parser parser.y parser.c)
add_dependencies(some_target foo_parser)
```

Or to run only the specific `foo_parser` target, which generates the
parser-related files:

```sh
cmake --build <dir> --target foo_parser
```

### Module configuration

To specify minimum required Bison version other than the module's default,
`find_package(BISON)` can be called before the `php_bison()`:

```cmake
find_package(BISON 3.7)
include(PHP/Bison)
php_bison(...)
```

Set `PHP_BISON_*` variables to override module default configuration:

```cmake
set(PHP_BISON_VERSION_DOWNLOAD 3.7)
include(PHP/Bison)
php_bison(...)
```
#]=============================================================================]

################################################################################
# Configuration.
################################################################################

macro(_php_bison_config)
  # Minimum required bison version.
  if(NOT PHP_BISON_VERSION)
    set(PHP_BISON_VERSION 3.0.0)
  endif()

  # If bison is not found on the system, set which version to download.
  if(NOT PHP_BISON_VERSION_DOWNLOAD)
    set(PHP_BISON_VERSION_DOWNLOAD 3.8.2)
  endif()
endmacro()

_php_bison_config()

include_guard(GLOBAL)

include(FeatureSummary)

# Configuration after find_package() in this module.
macro(_php_bison_config_options)
  # Add --no-lines (-l) option to not output '#line' directives.
  if(NOT PHP_BISON_OPTIONS)
    if(CMAKE_SCRIPT_MODE_FILE)
      set(PHP_BISON_OPTIONS --no-lines)
    else()
      set(PHP_BISON_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-lines>)
    endif()

    # Report all warnings.
    list(APPEND PHP_BISON_OPTIONS -Wall)
  endif()
endmacro()

################################################################################
# Functions.
################################################################################

function(php_bison name input output)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "ADD_DEFAULT_OPTIONS;CODEGEN;HEADER;VERBOSE;ABSOLUTE_PATHS" # options
    "HEADER_FILE;WORKING_DIRECTORY;REPORT_FILE" # one-value keywords
    "OPTIONS;DEPENDS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(parsed_HEADER AND parsed_HEADER_FILE)
    message(
      AUTHOR_WARNING
      "When 'HEADER_FILE' is specified, remove redundant 'HEADER' option."
    )
  endif()

  if(parsed_REPORT_FILE AND NOT parsed_VERBOSE)
    message(FATAL_ERROR "'REPORT_FILE' option requires also 'VERBOSE' option.")
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
  set(extraOutputs "")

  _php_bison_process_header_file()
  _php_bison_set_package_properties()

  get_property(packageType GLOBAL PROPERTY _CMAKE_BISON_TYPE)
  set(quiet "")
  if(NOT packageType STREQUAL "REQUIRED")
    set(quiet "QUIET")
  endif()

  _php_bison_config()

  # Skip consecutive calls if downloading or outer find_package() was called.
  if(NOT TARGET Bison::Bison AND NOT DEFINED BISON_FOUND)
    find_package(BISON ${PHP_BISON_VERSION} ${quiet})
  endif()

  if(
    NOT BISON_FOUND
    AND PHP_BISON_VERSION_DOWNLOAD
    AND packageType STREQUAL "REQUIRED"
    AND NOT CMAKE_SCRIPT_MODE_FILE
    # TODO: Support for other platforms.
    AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"
  )
    _php_bison_download()
  endif()

  # Set working directory.
  if(NOT parsed_WORKING_DIRECTORY)
    if(PHP_BISON_WORKING_DIRECTORY)
      set(parsed_WORKING_DIRECTORY ${PHP_BISON_WORKING_DIRECTORY})
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

  _php_bison_process_options()
  _php_bison_process_header_option()
  _php_bison_process_verbose_option()

  if(NOT CMAKE_SCRIPT_MODE_FILE)
    add_custom_target(${name} SOURCES ${input} DEPENDS ${outputs})
  endif()

  # Skip generation, if generated files are provided by the release archive.
  if(NOT BISON_FOUND AND NOT packageType STREQUAL "REQUIRED")
    return()
  endif()

  _php_bison_get_commands(commands)

  # Assemble status message.
  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relativePath
  )
  set(message "[bison] Generating ${relativePath} with Bison ${BISON_VERSION}")

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
      $<TARGET_NAME_IF_EXISTS:Bison::Bison>
    COMMENT "${message}"
    VERBATIM
    COMMAND_EXPAND_LISTS
    ${codegen}
    WORKING_DIRECTORY ${parsed_WORKING_DIRECTORY}
  )
endfunction()

# Process options.
function(_php_bison_process_options)
  _php_bison_config_options()

  set(options ${parsed_OPTIONS})

  if(PHP_BISON_OPTIONS AND parsed_ADD_DEFAULT_OPTIONS)
    list(PREPEND options ${PHP_BISON_OPTIONS})
  endif()

  # Remove any generator expressions when running in script mode.
  if(CMAKE_SCRIPT_MODE_FILE)
    list(TRANSFORM options GENEX_STRIP)
  endif()

  return(PROPAGATE options)
endfunction()

# Process HEADER_FILE.
function(_php_bison_process_header_file)
  if(NOT parsed_HEADER AND NOT parsed_HEADER_FILE)
    return()
  endif()

  if(parsed_HEADER_FILE)
    set(header ${parsed_HEADER_FILE})
    cmake_path(
      ABSOLUTE_PATH
      header
      BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      NORMALIZE
    )
  else()
    # Produce default header path generated by bison (see option --header).
    cmake_path(GET output EXTENSION LAST_ONLY extension)
    string(REPLACE "c" "h" extension "${extension}")
    if(NOT extension)
      set(extension ".h")
    endif()
    cmake_path(
      REPLACE_EXTENSION
      output
      LAST_ONLY
      "${extension}"
      OUTPUT_VARIABLE header
    )
  endif()

  list(APPEND outputs ${header})

  return(PROPAGATE header outputs)
endfunction()

# Process HEADER and HEADER_FILE options.
function(_php_bison_process_header_option)
  if(NOT parsed_HEADER AND NOT parsed_HEADER_FILE)
    return()
  endif()

  # Bison versions 3.8 and later introduced the --header=[FILE] (-H) option.
  # For prior versions the --defines=[FILE] (-d) option can be used.
  if(parsed_HEADER_FILE)
    if(parsed_ABSOLUTE_PATHS)
      set(headerArgument "${header}")
    else()
      cmake_path(
        RELATIVE_PATH
        header
        BASE_DIRECTORY ${parsed_WORKING_DIRECTORY}
        OUTPUT_VARIABLE headerArgument
      )
    endif()

    if(BISON_VERSION VERSION_LESS 3.8)
      list(APPEND options --defines=${headerArgument})
    else()
      list(APPEND options --header=${headerArgument})
    endif()
  else()
    if(BISON_VERSION VERSION_LESS 3.8)
      list(APPEND options -d)
    else()
      list(APPEND options --header)
    endif()
  endif()

  return(PROPAGATE options)
endfunction()

# Process the VERBOSE and REPORT_FILE options.
function(_php_bison_process_verbose_option)
  if(NOT parsed_VERBOSE)
    return()
  endif()

  list(APPEND options --verbose)

  if(NOT parsed_REPORT_FILE)
    cmake_path(GET output FILENAME reportFile)
    cmake_path(GET output EXTENSION extension)

    # Bison treats output files <parser-output-filename>.tab.<last-extension>
    # differently. It removes the '.tab' part of the extension and creates
    # <parser-output-filename>.output file. Elsewhere, it replaces only the
    # last extension with '.output'.
    if(extension MATCHES "\\.tab\\.([^.]+)$")
      string(
        REGEX REPLACE
        "\\.tab\\.${CMAKE_MATCH_1}$"
        ".output"
        reportFile
        "${reportFile}"
      )
    else()
      cmake_path(REPLACE_EXTENSION reportFile LAST_ONLY "output")
    endif()
  else()
    set(reportFile ${parsed_REPORT_FILE})
  endif()

  cmake_path(
    ABSOLUTE_PATH
    reportFile
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    NORMALIZE
  )

  list(APPEND extraOutputs "${reportFile}")
  list(APPEND options --report-file=${reportFile})

  return(PROPAGATE options extraOutputs)
endfunction()

# Set BISON package properties TYPE and PURPOSE. If parser-related output files
# are already generated, for example, shipped with the released archive, then
# BISON package type is set to RECOMMENDED. If generated files are not
# available, for example, when building from a Git repository, type is set to
# REQUIRED to generate files during the build.
function(_php_bison_set_package_properties)
  set_package_properties(BISON PROPERTIES TYPE RECOMMENDED)

  foreach(output IN LISTS outputs)
    if(NOT EXISTS ${output})
      set_package_properties(BISON PROPERTIES TYPE REQUIRED)
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
    set(purpose "Necessary to generate parser files.")
  else()
    set(purpose "Necessary to generate ${relativePath} parser files.")
  endif()
  set_package_properties(BISON PROPERTIES PURPOSE "${purpose}")
endfunction()

# Assemble commands for add_custom_command() and execute_process().
function(_php_bison_get_commands result)
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

  # Bison cannot create output directories. Ensure any required directories for
  # the generated files are created if they don't already exist.
  set(directories "")
  foreach(output IN LISTS outputs extraOutputs)
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
    ${BISON_EXECUTABLE}
    ${options}
    ${inputArgument}
    --output ${outputArgument}
  )

  return(PROPAGATE ${result})
endfunction()

# Download and build Bison if not found.
function(_php_bison_download)
  set(BISON_VERSION ${PHP_BISON_VERSION_DOWNLOAD})
  set(BISON_FOUND TRUE)

  if(TARGET Bison::Bison)
    return(PROPAGATE BISON_FOUND BISON_VERSION)
  endif()

  message(STATUS "Bison ${BISON_VERSION} will be downloaded at build phase")

  include(ExternalProject)

  ExternalProject_Add(
    bison
    URL https://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CONFIGURE_COMMAND
      <SOURCE_DIR>/configure
      --disable-dependency-tracking
      --disable-yacc
      --enable-silent-rules
      --prefix=<INSTALL_DIR>
    LOG_INSTALL TRUE
  )

  # Set bison executable.
  ExternalProject_Get_Property(bison INSTALL_DIR)
  set_property(CACHE BISON_EXECUTABLE PROPERTY VALUE ${INSTALL_DIR}/bin/bison)

  add_executable(Bison::Bison IMPORTED GLOBAL)
  set_target_properties(
    Bison::Bison
    PROPERTIES IMPORTED_LOCATION ${BISON_EXECUTABLE}
  )
  add_dependencies(Bison::Bison bison)

  # Move dependency to PACKAGES_FOUND.
  get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
  list(REMOVE_ITEM packagesNotFound BISON)
  set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
  get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
  set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND BISON)

  return(PROPAGATE BISON_FOUND BISON_VERSION)
endfunction()
