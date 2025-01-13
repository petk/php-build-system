<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/Bison.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Bison.cmake)

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

This creates a target `<name>` and adds a command that generates parser file
`<output>` from the given `<input>` template file using the Bison parser
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

* `PHP_BISON_VERSION_DOWNLOAD` - When Bison cannot be found on the system or the
  found version is not suitable, this module can also download and build it from
  its release archive sources as part of the project build. Set which version
  should be downloaded.

* `PHP_BISON_WORKING_DIRECTORY` - Set the default global working directory
  for all `php_bison()` invocations in the directory scope where the
  `WORKING_DIRECTORY <directory>` option is not set.

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
# For other build types, including the script modes (CMAKE_ROLE is not PROJECT):
#   bison --yacc foo.y --output foo.c
```

### Target usage

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

### Module configuration

To specify different minimum required Bison version than the module's default,
the `find_package(BISON)` can be called before `php_bison()`:

```cmake
include(PHP/Bison)
find_package(BISON 3.7)
php_bison(...)
```
