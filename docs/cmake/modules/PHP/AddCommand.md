<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/AddCommand.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/AddCommand.cmake)

# PHP/AddCommand

This module provides a command to run PHP command-line executable.

Load this module in a CMake project with:

```cmake
include(PHP/AddCommand)
```

A common issue in build systems is the generation of files with the project
program executable. In PHP there are two main issues this module resolves:

* When PHP command-line executable is found on the host system it can be used to
  generate some files during the build phase. This is the most simple and
  developer-friendly way to use as such files can be generated during the build
  phase directly.

* When building php-src and PHP is not found on the host system, ideally those
  files could be also generated after the PHP CLI SAPI executable is built in
  the php-src project itself. However, this can quickly bring cyclic
  dependencies between the target at hand, PHP CLI and the generated files. This
  module provides a fallback to the PHP CLI SAPI executable in this case without
  introducing cyclic dependencies. In such case, inconvenience is that two build
  steps might need to be done in order to generate the entire project once the
  files have been regenerated.

For example, see the `Zend/zend_vm_gen.php` script in php-src repository to
better understand this issue. It is used to generate source files such as
`Zend/zend_vm_execute.h` and uses PHP command-line interpreter if found on the
host system, or the built CLI SAPI executable.

## Commands

This module provides the following commands:

### `php_add_command()`

Adds a build rule to the generated build system and uses either PHP found on the
host, or the built PHP CLI SAPI executable at the end of the build phase:

```cmake
php_add_command(
  <target-name>
  [EXCLUDE_FROM_ALL | AS_TARGET]
  ARGS <arguments>...
  [REQUIRED_EXTENSIONS <extensions>...]
  [OPTIONAL_EXTENSIONS <extensions>...]
  [MIN_PHP_HOST_VERSION <version>]
  [ONLY_HOST_PHP | ONLY_SAPI_CLI]
  [OUTPUT <output-files>...]
  [DEPENDS <dependent-files>...]
  [COMMENT <comment>...]
  [WORKING_DIRECTORY <dir>]
)
```

The arguments are:

* `<target-name>`

  Unique target name providing the PHP command. This target can be also manually
  executed after the configuration phase with:

  ```sh
  cmake --build <build-dir> -t <target-name>
  ```

* `EXCLUDE_FROM_ALL`

  Optional. Indicates that this command should not be automatically executed
  during the build and is intended to be only run explicitly with:

  ```sh
  cmake --build <build-dir> -t <target-name>
  ```

* `AS_TARGET`

  Optional. Indicates that a `add_custom_target()` command will be used to run
  the PHP command instead of the `add_custom_command()` when:

  * building in php-src tree
  * no suitable PHP was found on the host system
  * built PHP CLI SAPI will be used for running the command

  This is intended to avoid cyclic dependencies between targets and PHP CLI SAPI
  executable.

* `ARGS <arguments>...`

  A list of arguments passed to the PHP executable command (the PHP CLI
  executable and options for shared extensions are automatically prepended to
  these arguments).

* `REQUIRED_EXTENSIONS <extensions>...`

  Optional. A list of required PHP extensions for this PHP command. Extensions
  can be listed by their name, e.g., `tokenizer`, `zlib`, etc. If any of the
  specified extensions are not enabled, target isn't added.

* `OPTIONAL_EXTENSIONS <extensions>...`

  Optional. A list of optional PHP extensions for this PHP command. Extensions
  can be listed by their name, e.g., `tokenizer`, `zlib`, etc. Target is added
  regardless whether any of the specified extensions are enabled or not.

* `MIN_PHP_HOST_VERSION <version>`

  Optional. A minimum required PHP version when PHP is found on the host system
  for using PHP command. If insufficient version is found, PHP CLI target from
  the current build will be used instead of the PHP executable from the host
  system. If this argument is not provided, the minimum required PHP version is
  specified by the `find_package(PHP <version>)` requirement when finding PHP on
  the host.

* `ONLY_HOST_PHP` or `ONLY_SAPI_CLI`

  Optional. Specifies, which PHP to use for running the command. If the
  `ONLY_HOST_PHP` option is specified, only the PHP on the host system (if
  found) will be used. Or vice versa, if the `ONLY_SAPI_CLI` option is
  specified, only the built PHP SAPI CLI executable will be used to run the PHP
  command when building inside php-src. If neither option is specified, the
  command first uses the PHP from the host system if found, and if not found
  when building in php-src it falls back to using PHP SAPI CLI executable.

* `OUTPUT <output-files>...`

  A list of files the command is expected to produce. When these output files
  are added, for example, to a list of sources in some project target, then an
  internal dependency is created and the PHP command is executed automatically
  during the build phase (or at the end of the build phase depending). If this
  argument is not provided, no dependency between project targets is created
  internally (used in cases where the PHP command is intended to be executed
  manually after the build phase with
  `cmake --build <build-dir> -t <target-name>`).

  Relative paths are interpreted as being relative to the current binary
  directory (`CMAKE_CURRENT_BINARY_DIR`).

* `DEPENDS <dependent-files>...`

  Optional. A list of files or targets on which the command depends.

  Relative file paths are managed the same way as in the DEPENDS argument of the
  [`add_custom_command()`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
  command. For clarity, use absolute paths when referring to files.

* `COMMENT <comment>...`

  Optional. A comment that is displayed before the command is executed. If more
  than one `<comment>` string is given, they are concatenated into a single
  string with no separator between them.

* `WORKING_DIRECTORY <dir>`

  Optional. A directory where the PHP command will be executed from. Relative
  paths are interpreted as being relative to the current binary directory
  (`CMAKE_CURRENT_BINARY_DIR`). If not specified, it is set to the current
  binary directory.

This command acts similar to
[`add_custom_command`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
and
[`add_custom_target()`](https://cmake.org/cmake/help/latest/command/add_custom_target.html)
commands, except that when PHP is not found on the host system, the `DEPENDS`
argument doesn't add dependencies among targets but instead checks their
timestamps manually and executes the assembled PHP command only when needed.

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
  AS_TARGET
  ARGS ${CMAKE_CURRENT_SOURCE_DIR}/generate-something.php
  REQUIRED_EXTENSIONS tokenizer
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/generated_source.c
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/data.php
  COMMENT "Generating something"
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
  EXCLUDE_FROM_ALL
  ARGS ${CMAKE_CURRENT_SOURCE_DIR}/generate-foo.php
  COMMENT "Generating foo"
)
```

This will add a target `php_generate_foo` during the configuration phase, but it
will not be automatically executed. This can be used in specific cases where the
generated file is intended to be generated during the php-src development and
not by the end php-src users. It can be manually called after the configuration
phase:

```sh
# Configuration phase:
cmake -S <source-dir> -B <build-dir>

# Build step with running only the specified target:
cmake --build <build-dir> -t php_generate_foo
```
