#[=============================================================================[
# PHP/Bison

This module finds the Bison command-line parser generator and provides a command
to generate parser files with Bison:

```cmake
include(PHP/Bison)
```

## Commands

This module provides the following commands:

### `php_bison()`

Generates parser file from the given template file using the Bison generator:

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

This command creates a target `<name>` and adds a command that generates parser
file `<output>` from the given `<input>` template file using the Bison parser
generator. Relative source file path `<input>` is interpreted as being relative
to the current source directory. Relative `<output>` file path is interpreted as
being relative to the current binary directory. If generated files are already
available (for example, shipped with the released archive), and Bison is not
found, it will create a target but skip the `bison` command-line execution.

When the `CMAKE_ROLE` global property value is not `PROJECT` (running is some
script mode) it generates the files right away without creating a target. For
example, in command-line scripts.

#### Options

* `HEADER` - Generate also a header file automatically.

* `HEADER_FILE <header>` - Generate a specified header file `<header>`. Relative
  header file path is interpreted as being relative to the current binary
  directory.

* `ADD_DEFAULT_OPTIONS` - When specified, the options from the
  `PHP_BISON_OPTIONS` configuration variable are prepended to the current
  `bison` command-line invocation. This module provides some sensible defaults.

* `OPTIONS <options>...` - List of additional options to pass to the `bison`
  command-line tool. Supports generator expressions. In script modes
  (`CMAKE_ROLE` is not `PROJECT`) generator expressions are stripped as they
  can't be determined.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `VERBOSE` - Adds the `--verbose` (`-v`) command-line option and creates extra
  output file `<parser-output-filename>.output` in the current binary directory.
  Report contains verbose grammar and parser descriptions.

* `REPORT_FILE <file>` - Adds the `--report-file=<file>` command-line option and
  creates verbose information report in the specified `<file>`. This option must
  be used with the `VERBOSE` option. Relative file path is interpreted as being
  relative to the current binary directory.

* `CODEGEN` - Adds the `CODEGEN` option to the `add_custom_command()` call. This
  option is available starting with CMake 3.31 when the policy `CMP0171` is set
  to `NEW`. It provides a `codegen` target for convenience, allowing to run only
  code-generation-related targets while skipping the majority of the build:

  ```sh
  cmake --build <dir> --target codegen
  ```

* `WORKING_DIRECTORY <directory>` - The path where the `bison` is executed.
  Relative `<directory>` path is interpreted as being relative to the current
  binary directory. If not set, `bison` is by default executed in the
  `PHP_SOURCE_DIR` when building the php-src repository. Otherwise it is
  executed in the directory of the `<output>` file. If variable
  `PHP_BISON_WORKING_DIRECTORY` is set before calling the `php_bison()` without
  this option, it will set the default working directory to that instead.

* `ABSOLUTE_PATHS` - Whether to use absolute file paths in the `bison`
  command-line invocations. By default all file paths are added as relative to
  the working directory. Using relative paths is convenient when line directives
  (`#line ...`) are generated in the output files committed to Git repository.

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

* `PHP_BISON_GNU_VERSION_DOWNLOAD` - When Bison cannot be found on the system or
  the found version is not suitable, this module can also download and build it
  from its release archive sources as part of the project build. This variable
  specifies which GNU Bison version should be downloaded.

* `PHP_BISON_WIN_VERSION_DOWNLOAD` - When Bison cannot be found on the Windows
  host system or the found version is not suitable, this module can also
  download [`win_bison.exe`](https://github.com/lexxmark/winflexbison). This
  variable specifies which `winflexbison` version should be downloaded.

* `PHP_BISON_WORKING_DIRECTORY` - Set the default global working directory
  for all `php_bison()` invocations in the directory scope where the
  `WORKING_DIRECTORY <directory>` option is not set.

## Examples

### Example: Basic usage

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

### Example: Generator expressions

```cmake
include(PHP/Bison)

php_bison(foo foo.y foo.c OPTIONS $<$<CONFIG:Debug>:--debug> --yacc)
# When build type is Debug, this will run:
#   bison --debug --yacc foo.y --output foo.c
# For other build types, including the script modes (CMAKE_ROLE is not PROJECT):
#   bison --yacc foo.y --output foo.c
```

### Example: Target usage

Target created by `php_bison()` can be used to specify additional dependencies:

```cmake
# CMakeLists.txt

include(PHP/Bison)

php_bison(foo_parser parser.y parser.c)
add_dependencies(some_target foo_parser)
```

Running only the `foo_parser` target to generate the parser-related files:

```sh
cmake --build <dir> --target foo_parser
```

### Example: Module configuration

To specify different minimum required Bison version than the module's default,
the `find_package(BISON)` can be called before `php_bison()`:

```cmake
include(PHP/Bison)
find_package(BISON 3.7)
php_bison(...)
```
#]=============================================================================]

################################################################################
# Configuration.
################################################################################

macro(_php_bison_config)
  # Minimum required Bison version.
  if(NOT PHP_BISON_VERSION)
    set(PHP_BISON_VERSION 3.0.0)
  endif()

  # If Bison is not found on the system, set which version to download for
  # POSIX platforms that might support GNU Bison.
  if(NOT PHP_BISON_GNU_VERSION_DOWNLOAD)
    set(PHP_BISON_GNU_VERSION_DOWNLOAD 3.8.2)
  endif()

  # If Bison is not found on the Windows host system, set which winflexbison
  # version to download.
  if(NOT PHP_BISON_WIN_VERSION_DOWNLOAD)
    set(PHP_BISON_WIN_VERSION_DOWNLOAD 2.5.25)
  endif()
endmacro()

_php_bison_config()

include_guard(GLOBAL)

include(FeatureSummary)

# Configuration after find_package() in this module.
macro(_php_bison_config_options)
  if(NOT PHP_BISON_OPTIONS)
    # Add --no-lines (-l) option to not output '#line' directives.
    get_property(_role GLOBAL PROPERTY CMAKE_ROLE)
    if(_role STREQUAL "PROJECT")
      set(PHP_BISON_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-lines>)
    else()
      set(PHP_BISON_OPTIONS --no-lines)
    endif()
    unset(_role)

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

  # Skip consecutive find_package() calls when:
  # - project calls php_bison() multiple times and Bison will be downloaded
  # - the outer find_package() was called prior to php_bison()
  # - running consecutive configuration phases and Bison will be downloaded
  if(
    NOT TARGET Bison::Bison
    AND NOT DEFINED BISON_FOUND
    AND NOT _PHP_BISON_DOWNLOAD
  )
    find_package(BISON ${PHP_BISON_VERSION} ${quiet})
  endif()

  get_property(role GLOBAL PROPERTY CMAKE_ROLE)

  if(
    NOT BISON_FOUND
    AND PHP_BISON_GNU_VERSION_DOWNLOAD
    AND PHP_BISON_WIN_VERSION_DOWNLOAD
    AND packageType STREQUAL "REQUIRED"
    AND role STREQUAL "PROJECT"
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

  if(role STREQUAL "PROJECT")
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
  set(message "[Bison] Generating ${relativePath} with Bison ${BISON_VERSION}")

  if(NOT role STREQUAL "PROJECT")
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
  get_property(role GLOBAL PROPERTY CMAKE_ROLE)
  if(NOT role STREQUAL "PROJECT")
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
  set(BISON_VERSION ${PHP_BISON_GNU_VERSION_DOWNLOAD})
  set(BISON_FOUND TRUE)

  if(TARGET Bison::Bison)
    return(PROPAGATE BISON_FOUND BISON_VERSION)
  endif()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    _php_bison_download_windows()
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    _php_bison_download_gnu()
  else()
    # TODO: Add support for more platforms.
    message(
      WARNING
      "Bison couldn't be downloaded. The current platform ${CMAKE_SYSTEM_NAME} "
      "is not yet supported by PHP/Bison module. Please install Bison manually."
    )
    return()
  endif()

  add_executable(Bison::Bison IMPORTED GLOBAL)
  set_target_properties(
    Bison::Bison
    PROPERTIES IMPORTED_LOCATION ${BISON_EXECUTABLE}
  )

  # Target created by ExternalProject:
  if(TARGET bison)
    add_dependencies(Bison::Bison bison)
  endif()

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "BISON")
    get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound ${package})
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${packagesNotFound})
    get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
    list(FIND packagesFound ${package} found)
    if(found EQUAL -1)
      set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${package})
    endif()
  endblock()

  set(
    _PHP_BISON_DOWNLOAD
    TRUE
    CACHE INTERNAL
    "Internal marker whether the Bison will be downloaded."
  )

  return(PROPAGATE BISON_FOUND BISON_VERSION)
endfunction()

# Downloads GNU Bison.
function(_php_bison_download_gnu)
  message(STATUS "GNU Bison ${BISON_VERSION} will be downloaded at build phase")

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

  ExternalProject_Get_Property(bison INSTALL_DIR)

  set_property(CACHE BISON_EXECUTABLE PROPERTY VALUE ${INSTALL_DIR}/bin/bison)
endfunction()

# Downloads https://github.com/lexxmark/winflexbison.
function(_php_bison_download_windows)
  message(
    STATUS
    "Downloading win_bison ${BISON_VERSION} (${PHP_BISON_WIN_VERSION_DOWNLOAD})"
  )

  get_directory_property(dir EP_BASE)
  if(NOT dir)
    set(dir "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles")
  endif()

  set(file "${dir}/win_flex_bison.zip")

  file(
    DOWNLOAD
    "https://github.com/lexxmark/winflexbison/releases/download/v${PHP_BISON_WIN_VERSION_DOWNLOAD}/win_flex_bison-${PHP_BISON_WIN_VERSION_DOWNLOAD}.zip"
    ${file}
    SHOW_PROGRESS
  )

  file(ARCHIVE_EXTRACT INPUT "${file}" DESTINATION "${dir}/win_flex_bison")

  set_property(
    CACHE
    BISON_EXECUTABLE
    PROPERTY VALUE "${dir}/win_flex_bison/win_bison.exe"
  )
endfunction()
