#[=============================================================================[
# PHP/AddCustomCommand

Adds a custom PHP command that uses host PHP or built PHP CLI.

Load this module in a CMake project with:

```cmake
include(PHP/AddCustomCommand)
```

This module is built on top of the CMake
[`add_custom_command`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
and [`add_custom_target()`](https://cmake.org/cmake/help/latest/command/add_custom_target.html)
commands.

A common issue in build systems is the generation of files with the project
program itself. Here are two main cases:

* PHP is found on the host system: this is the most simple and
  developer-friendly way to use as some files can be generated during the build
  phase.

* When PHP is not found on the host system, ideally the files could be generated
  after the PHP CLI binary is built in the current project itself. However, this
  can quickly bring cyclic dependencies between the target at hand, PHP CLI and
  the generated files. In such case, inconvenience is that two build steps might
  need to be done in order to generate the entire project once the file has been
  regenerated.

## Commands

This module provides the following command:

### `php_add_custom_command()`

Adds a custom build rule to the generated build system:

```cmake
php_add_custom_command(
  <unique-symbolic-target-name>
  OUTPUT <output-files>...
  DEPENDS <dependent-files>...
  PHP_COMMAND <arguments>...
  [COMMENT <comment>]
  [VERBATIM]
)
```

The arguments are:

* `<uniquie-symbolic-target-name>` - The target name providing the custom
  command.
* `OUTPUT <output-files>...` - A list of files the command is expected to
  produce.
* `DEPENDS <dependent-files>...` - A list of files on which the command depends.
* `PHP_COMMAND <arguments>...` - A list of arguments passed to the PHP
  executable command.
* `COMMENT <comment>` - Optional comment that is displayed before the command is
  executed.
* `VERBATIM` - Option that properly escapes all arguments to the command.

This command acts similar to `add_custom_command()` and `add_custom_target()`
commands, except that when PHP is not found on the host system, the `DEPENDS`
argument doesn't add dependencies among targets but instead checks their
timestamps manually and executes the `PHP_COMMAND` only when needed.

## Examples

In the following example, this module is used to generate a source file with
PHP:

```cmake
# CMakeLists.txt

include(PHP/AddCustomCommand)

php_add_custom_command(
  php_generate_something
  OUTPUT
    ${CMAKE_CURRENT_SOURCE_DIR}/generated_source.c
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/data.php
  PHP_COMMAND
    -n
    ${CMAKE_CURRENT_SOURCE_DIR}/generate-something.php
  COMMENT "Generate something"
  VERBATIM
)

target_sources(example PRIVATE main.c generated_source.c)
```
#]=============================================================================]

include_guard(GLOBAL)

function(php_add_custom_command)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed                       # prefix
    "VERBATIM"                   # options
    "COMMENT"                    # one-value keywords
    "OUTPUT;DEPENDS;PHP_COMMAND" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "1st argument (target name) is missing.")
  endif()

  if(parsed_VERBATIM)
    set(verbatim VERBATIM)
  else()
    set(verbatim "")
  endif()

  if(PHP_HOST_FOUND)
    add_custom_command(
      OUTPUT ${parsed_OUTPUT}
      COMMAND ${PHP_HOST_EXECUTABLE} ${parsed_PHP_COMMAND}
      DEPENDS ${parsed_DEPENDS}
      COMMENT "${parsed_COMMENT}"
      ${verbatim}
    )

    return()
  endif()

  if(NOT TARGET PHP::sapi::cli)
    return()
  endif()

  if(NOT CMAKE_CROSSCOMPILING)
    set(php_executable "$<TARGET_FILE:PHP::sapi::cli>")
  elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
    set(php_executable "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:PHP::sapi::cli>")
  else()
    return()
  endif()

  add_custom_target(
    ${ARGV0}
    ALL
    COMMAND
      ${CMAKE_COMMAND}
      -D "PHP_EXECUTABLE=${php_executable}"
      -D "OUTPUT=${parsed_OUTPUT}"
      -D "PHP_COMMAND=${parsed_PHP_COMMAND}"
      -D "DEPENDS=${parsed_DEPENDS}"
      -D "COMMENT=${parsed_COMMENT}"
      -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/AddCustomCommand/RunCommand.cmake
    ${verbatim}
  )
endfunction()
