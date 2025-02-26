<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/Re2c.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Re2c.cmake)

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

When the `CMAKE_ROLE` global property value is not `PROJECT` (running is some
script mode) it generates the files right away without creating a target. For
example, in command-line scripts.

#### Options

* `HEADER <header>` - Generate a given `<header>` file. Relative header file
  path is interpreted as being relative to the current binary directory.

* `ADD_DEFAULT_OPTIONS` - When specified, the options from the
  `PHP_RE2C_OPTIONS` configuration variable are prepended to the current
  `re2c` command-line invocation. This module provides some sensible defaults.

* `OPTIONS <options>...` - List of additional options to pass to the `re2c`
  command-line tool. Supports generator expressions. In script modes
  (`CMAKE_ROLE` is not `PROJECT`) generator expressions are stripped as they
  can't be determined.

* `DEPENDS <depends>...` - Optional list of dependent files to regenerate the
  output file.

* `COMPUTED_GOTOS <TRUE|FALSE>` - Set to `TRUE` to add the `--computed-gotos`
  (`-g`) command-line option if the non-standard C computed goto extension is
  supported by the C compiler. When calling `re2c()` in some script mode
  (`CMAKE_ROLE` value other than `PROJECT`), compiler checking is skipped and
  option is added unconditionally.

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

### Usage

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
# For other build types, including the script modes (CMAKE_ROLE is not PROJECT):
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
