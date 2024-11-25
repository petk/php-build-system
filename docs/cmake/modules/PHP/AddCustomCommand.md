<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/AddCustomCommand.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/AddCustomCommand.cmake)

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
