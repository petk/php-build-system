# FindRE2C

See: [FindRE2C.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindRE2C.cmake)

## Basic usage

```cmake
include(cmake/FindRE2C.cmake)
```

Find re2c.

The minimum required version of re2c can be specified using the standard CMake
syntax, e.g. 'find_package(RE2C 0.15.3)'.

Result variables:

* `RE2C_FOUND` - Whether re2c program was found.
* `RE2C_VERSION` - Version of re2c program.

Cache variables:

* `RE2C_EXECUTABLE` - Path to the re2c program.

Custom target:

* `re2c_generate_files` - A custom target for generating lexer files:

  ```sh
  cmake --build <dir> -t re2c_generate_files
  ```

  or to add it as a dependency to other targets:

  ```cmake
  add_dependencies(some_target re2c_generate_files)
  ```

Hints:

* `RE2C_DEFAULT_OPTIONS` - A `;-`list of default global options to pass to re2c
  for all `re2c_target()` invocations. Set before calling the
  `find_package(RE2C)`. Options are prepended to additional options passed with
  `re2c_target()` arguments.

* `RE2C_ENABLE_DOWNLOAD` - This module can also download and build re2c from its
  Git repository using the `FetchContent` module. Set to `TRUE` to enable
  downloading re2c, when not found on the system or system version is not
  suitable.

* `RE2C_USE_COMPUTED_GOTOS` - Set to `TRUE` before calling `find_package(RE2C)`
  to enable the re2c `--computed-gotos` option if the non-standard C
  `computed goto` extension is supported by the C compiler.

If re2c is found, the following function is exposed:

```cmake
re2c_target(
  <name>
  <input>
  <output>
  [HEADER <header>]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [NO_DEFAULT_OPTIONS]
  [NO_COMPUTED_GOTOS]
)
```

* `<name>` - Target name.
* `<input>` - The re2c template file input. Relative source file path is
  interpreted as being relative to the current source directory.
* `<output>` - The output file. Relative output file path is interpreted as
  being relative to the current binary directory.
* `HEADER` - Generate a <header> file. Relative header file path is interpreted
  as being relative to the current binary directory.
* `OPTIONS` - List of additional options to pass to re2c command-line tool.
* `DEPENDS` - Optional list of dependent files to regenerate the output file.
* `NO_DEFAULT_OPTIONS` - If specified, then the options from
  `RE2C_DEFAULT_OPTIONS` are not passed to the re2c invocation.
* `NO_COMPUTED_GOTOS` - If specified when using the `RE2C_USE_COMPUTED_GOTOS`,
  then the computed gotos option is not passed to the re2c invocation.
