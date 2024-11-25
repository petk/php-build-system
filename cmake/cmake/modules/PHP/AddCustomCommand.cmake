#[=============================================================================[
# PHP/AddCustomCommand

Add custom command.

This module is built on top of the CMake
[`add_custom_command`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
and [`add_custom_target()`](https://cmake.org/cmake/help/latest/command/add_custom_target.html)
commands.

A common issue in build systems is the generation of files with the project
program itself. Here are two main cases:
* PHP is found on the system: this is the most simple and developer-friendly to
  use as some files can be generated during the build phase.
* When PHP is not found on the system, ideally the files could be generated
  after the PHP CLI binary is built in the current project itself. However, this
  can quickly bring cyclic dependencies between the target at hand, PHP CLI and
  the generated files. In such case, inconvenience is that two build steps might
  need to be done in order to generate the entire project once the file has been
  regenerated.

This module exposes the following function:

```cmake
php_add_custom_command(
  <unique-symbolic-target-name>
  OUTPUT  ...
  DEPENDS ...
  PHP_COMMAND ...
  [COMMENT <comment>]
  [VERBATIM]
)
```

## Basic usage

It acts similar to `add_custom_command()` and `add_custom_target()`, except that
when PHP is not found on the system, the DEPENDS argument doesn't add
dependencies among targets but instead checks their timestamps manually and
executes the PHP_COMMAND only when needed.

```cmake
# CMakeLists.txt
include(PHP/AddCustomCommand)
php_add_custom_command(
  php_generate_something
  OUTPUT
    list of generated files
  DEPENDS
    list of files or targets that this generation depends on
  PHP_COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/generate-something.php
  COMMENT "Generate something"
  VERBATIM
)
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
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "1st argument (target name) is missing.")
  endif()

  if(parsed_VERBATIM)
    set(verbatim VERBATIM)
  else()
    set(verbatim)
  endif()

  if(PHPSystem_EXECUTABLE)
    add_custom_command(
      OUTPUT ${parsed_OUTPUT}
      COMMAND ${PHPSystem_EXECUTABLE} ${parsed_PHP_COMMAND}
      DEPENDS ${parsed_DEPENDS}
      COMMENT "${parsed_COMMENT}"
      ${verbatim}
    )

    return()
  endif()

  if(NOT TARGET php_cli)
    return()
  endif()

  if(NOT CMAKE_CROSSCOMPILING)
    set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
  elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
    set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:php_cli>")
  else()
    return()
  endif()

  set(targetName ${ARGV0})

  add_custom_target(
    ${targetName} ALL
    COMMAND ${CMAKE_COMMAND}
      -D "PHP_EXECUTABLE=${PHP_EXECUTABLE}"
      -D "OUTPUT=${parsed_OUTPUT}"
      -D "PHP_COMMAND=${parsed_PHP_COMMAND}"
      -D "DEPENDS=${parsed_DEPENDS}"
      -D "COMMENT=${parsed_COMMENT}"
      -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/AddCustomCommand/RunCommand.cmake
    ${verbatim}
  )
endfunction()
