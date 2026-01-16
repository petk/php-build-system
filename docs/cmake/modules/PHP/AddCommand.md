<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/AddCommand.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/AddCommand.cmake)

# PHP/AddCommand

This module provides a command to run PHP command-line executable.

Load this module in a CMake project with:

```cmake
include(PHP/AddCommand)
```

A common issue in build systems is the generation of files with the project
program executable. In PHP there are two main cases:

* When PHP command-line executable is found on the host system it can be used to
  generate some files during the build phase. This is the most simple and
  developer-friendly way to use as some files can be generated during the build
  phase directly.

* When building php-src and PHP is not found on the host system, ideally those
  files could be also generated after the PHP CLI SAPI executable is built in
  the php-src project itself. However, this can quickly bring cyclic
  dependencies between the target at hand, PHP CLI and the generated files. This
  module provides a fallback to the PHP CLI SAPI executable in this case without
  introducing cyclic dependencies. In such case, inconvenience is that two build
  steps might need to be done in order to generate the entire project once th
  files have been regenerated.

This module is a wrapper around the CMake
[`add_custom_command`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
and [`add_custom_target()`](https://cmake.org/cmake/help/latest/command/add_custom_target.html)
commands.

## Commands

This module provides the following commands:

### `php_add_command()`

Adds a custom build rule to the generated build system and uses either PHP found
on the host, or the built PHP CLI SAPI executable at the end of the build phase:

```cmake
php_add_command(
  <target-name>
  PHP_COMMAND <arguments>...
  [PHP_EXTENSIONS <extensions>...]
  [MIN_PHP_HOST_VERSION <version>]
  [OUTPUT <output-files>...]
  [DEPENDS <dependent-files>...]
  [COMMENT <comment>]
  [WORKING_DIRECTORY <dir>]
  [VERBATIM]
)
```

The arguments are:

* `<target-name>` - Unique target name providing the custom command.

  This target can be also manually executed after the configuration phase with:

  ```sh
  cmake --build <build-dir> -t <target-name>
  ```

* `PHP_COMMAND <arguments>...` - A list of arguments passed to the PHP
  executable command (the PHP CLI executable is automatically prepended to these
  arguments).

* `PHP_EXTENSIONS <extensions>...` - Optional list of required PHP extensions
  for this PHP command. Extensions are listed by their name, e.g., `tokenizer`,
  `zlib`, etc.

* `MIN_PHP_HOST_VERSION <version>` - Optional minimum required PHP version when
  PHP is found on the host system for using PHP command. If insufficient version
  is found, PHP CLI target from the current build will be used instead of the
  PHP executable from the host system. If this argument is not provided, the
  minimum required PHP version is specified by the `find_package(PHP <version>)`
  requirement when finding PHP on the host.

* `OUTPUT <output-files>...` - A list of files the command is expected to
  produce. When these output files are added, for example, to a list of sources
  in some project target, then an internal dependency is created and the PHP
  command is executed automatically during the build phase (or at the end of the
  build phase depending). If this argument is not provided, no dependency
  between project targets is created internally (used in cases where the PHP
  command is intended to be executed manually after the build phase with
  `cmake --build <build-dir> -t <target-name>`).

* `DEPENDS <dependent-files>...` - Optional list of files on which the command
  depends.

* `COMMENT <comment>` - Optional comment that is displayed before the command is
  executed.

* `WORKING_DIRECTORY <dir>` - Optional directory where the PHP command will be
  executed from.

* `VERBATIM` - Option that properly escapes all arguments to the command.

This command acts similar to `add_custom_command()` and `add_custom_target()`
commands, except that when PHP is not found on the host system, the `DEPENDS`
argument doesn't add dependencies among targets but instead checks their
timestamps manually and executes the `PHP_COMMAND` only when needed.

## Examples

### Example: Basic usage

In the following example, this module is used to generate the
`generated_source.c` source file with PHP. The `generate-something.php` PHP
script requires the `tokenizer` extension to be enabled.

```cmake
# CMakeLists.txt

include(PHP/AddCommand)

php_add_command(
  php_generate_something
  PHP_COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/generate-something.php
  PHP_EXTENSIONS tokenizer
  OUTPUT
    ${CMAKE_CURRENT_SOURCE_DIR}/generated_source.c
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/data.php
  COMMENT "Generating something"
  VERBATIM
)

target_sources(example PRIVATE main.c generated_source.c)
```

### Example: Creating a target that executes PHP manually

In the following example, this module is used to add a custom build rule that
runs the specified PHP command:

```cmake
include(PHP/AddCommand)

php_add_command(
  php_generate_foo
  PHP_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/generate-foo.php
  COMMENT "Generating foo"
  VERBATIM
)
```

This will add a target `php_generate_foo` during the configuration phase, but it
will not be automatically executed. This can be used in specific cases where
the generated file is intended to be generated during the php-src development
and not by the end php-src users. It can be manually called after the
configuration phase:

```sh
# Configuration phase:
cmake -S <source-dir> -B <build-dir>

# Build step with running only the specified target:
cmake --build <build-dir> -t php_generate_foo
```
