# CMake code style

This repository is following some of the established code style practices from
the CMake ecosystem.

* [1. Introduction](#1-introduction)
* [2. Code style](#2-code-style)
  * [2.1. General guidelines](#21-general-guidelines)
  * [2.2. Variable names](#22-variable-names)
  * [2.3. End commands](#23-end-commands)
  * [2.4. Module naming conventions](#24-module-naming-conventions)
  * [2.5. Booleans](#25-booleans)
  * [2.6. Functions and macros](#26-functions-and-macros)
* [3. Tools](#3-tools)
  * [3.1. cmake-format (by cmakelang project)](#31-cmake-format-by-cmakelang-project)
  * [3.2. cmake-lint (by cmakelang project)](#32-cmake-lint-by-cmakelang-project)
  * [3.3. cmakelint](#33-cmakelint)
* [4. See also](#4-see-also)
  * [4.1. bin/check-cmake.sh](#41-bincheck-cmakesh)
  * [4.2. Customized rules for cmake-format and cmake-lint in cmake-format.json](#42-customized-rules-for-cmake-format-and-cmake-lint-in-cmake-formatjson)
  * [4.3. Further resources for CMake code style](#43-further-resources-for-cmake-code-style)

## 1. Introduction

CMake is pretty forgiving when it comes to code style. Yet, using some frame on
how to code CMake files can improve overall code quality and understanding of
the build system when used by multiple developers.

For example, all CMake functions, macros, and commands are case insensitive.
These two are the same:

```cmake
add_library(foo foo.c bar.c)
```

```cmake
ADD_LIBRARY(foo foo.c bar.c)
```

Variables are on the other hand case sensitive.

## 2. Code style

### 2.1. General guidelines

* In general the **all-lowercase style** is preferred.

  ```cmake
  add_library(foo foo.c bar_baz.c)
  ```

### 2.2. Variable names

CMake variables can be categorized into several types:

* Cache internal variables

  These are set like this:

  ```cmake
  set(VAR <value> CACHE INTERNAL "Documentation string)
  ```

  These should be UPPER_CASE.

* Cache variables

  ```cmake
  set(VAR 1 CACHE BOOL "Documentation string")
  option(FOO "Documentation string" ON)
  ```

  These should be UPPER_CASE.

* Local variables

  Variables with a scope inside functions.

  These should be lower_case.

* Directory variables

  Variables with a scope inside the current `CMakeLists.txt` and its child
  directories with CMake files.

  If variable is meant to be used within other child directories these should
  be UPPER_CASE.

  Since there is no way to limit the scope of such directory variables to only
  current CMake file, the convention is to prefix them with underscore (`_`)
  to indicate they are meant for temporary use only inside current CMake file:

  ```cmake
  set(_temporary_variable "Foo")
  ```

* Variables named `_` can be used for values that are not important for code:

  ```cmake
  # For example, here only the matched value of CMAKE_MATCH_1 is important.
  string(REGEX MATCH "foo\\(([0-9]+)\\)" _ ${content})
  message(STATUS ${CMAKE_MATCH_1})
  ```

### 2.3. End commands

To make the code easier to read, use empty commands for `endif()`,
`endfunction()`, `endforeach()`, `endmacro()`, `endwhile()`, `else()`, and
similar end commands. The optional argument in end command is legacy CMake and
not recommended anymore.

For example, do this:

```cmake
if(FOO)
  some_command(...)
else()
  another_command(...)
endif()
```

and not this:

```cmake
if(BAR)
  some_other_command(...)
endif(BAR)
```

### 2.4. Module naming conventions

The find modules in this repository are named in form of `FindUPPERCASE.cmake`.
The utility modules are prefixed with `PHP` and then mostly following the form
of `PHPPascalCase.cmake` pattern for convenience to not collide with upstream
CMake modules.

### 2.5. Booleans

CMake treats the `1`, `ON`, `YES`, `TRUE`, `Y` as boolean true values and
`0`, `OFF`, `NO`, `FALSE`, `N`, `IGNORE`, `NOTFOUND`, the empty string, or if
value ends in the suffix `-NOTFOUND` as boolean false values. The named
constants are case-insensitive.

Possible simplifications for this repository and to not collide too much with
existing C code and configuration header `php_config.h`:

```cmake
# Options have ON/OFF values.
option(FOO "Documentation string" ON)

# Conditional variables have 1/0 values.
set(HAVE_FOO_H 1 CACHE INTERNAL "Documentation string")

# Elsewhere in commands, functions etc. TRUE/FALSE.
```

### 2.6. Functions and macros

Functions are preferred over macros because functions have their own variable
scope. Variables inside macros are visible from the outside scope.

Functions naming convention should follow the snake_case style.

Functions in CMake have global scope. Similarly as variables, functions that are
used only within a single CMake module or `CMakeLists.txt` file, can be prefixed
with underscore (`_`). Such prefix serves as an indicator to outer code "not to
use me."

## 3. Tools

There are some tools in different state of maintenance but they can be relevant
as they can help with formatting and linting CMake files.

### 3.1. cmake-format (by cmakelang project)

The [`cmake-format`](https://cmake-format.readthedocs.io/en/latest/) tool can
find formatting issues and sync the CMake code style:

```sh
cmake-format --check <cmake/CMakeLists.txt cmake/...>
```

It can utilize the configuration file (default `cmake-format.[json|py|yaml]`) or
by passing the `--config-files` or `-c` option:

```sh
cmake-format -c path/to/cmake-format.json --check -- <cmake/CMakeLists.txt cmake/...>
```

Default configuration in JSON format can be printed to stdout:

```sh
cmake-format --dump-config json
```

Option `--in-place` or `-i` fixes particular CMake file in-place instead of
dumping the formatted content to stdout:

```sh
cmake-format -i path/to/cmake/file
```

### 3.2. cmake-lint (by cmakelang project)

The [`cmake-lint`](https://cmake-format.readthedocs.io/en/latest/cmake-lint.html)
tool is part of the cmakelang project and can help with linting CMake files:

```sh
cmake-lint <cmake/CMakeLists.txt cmake/...>
```

This tool can also utilize the `cmake-format.[json|py|yaml]` file using the `-c`
option.

### 3.3. cmakelint

For linting there is also a separate and useful
[cmakelint](https://github.com/cmake-lint/cmake-lint) tool which similarly lints
and helps to better structure CMake files:

```sh
cmakelint <cmake/CMakeLists.txt cmake/...>
```

## 4. See also

### 4.1. bin/check-cmake.sh

For convenience there is a custom helper script added to this repository that
checks CMake files:

```sh
./bin/check-cmake.sh
```

### 4.2. Customized rules for cmake-format and cmake-lint in cmake-format.json

The `cmake-format.json` file is used to configure how `cmake-lint` and
`cmake-format` tools work.

There is `cmake/cmake/cmake-format.json` added to this repository and is used by
the custom `bin/check-cmake.sh` script. It includes only changed configuration
values from the upstream defaults.

* `disabled_codes`

  This option disables certain cmake-lint checks. This repository has simplified
  code style by disabling the following codes:

  * `C0111` - Missing docstring on function or macro declaration
  * `C0301` - Line too long
  * `C0307` - Bad indentation

  The cmake-lint checks codes are specified at
  [cmakelang documentation](https://cmake-format.readthedocs.io/en/latest/lint-implemented.html#)

### 4.3. Further resources for CMake code style

* [CMake developers docs](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html)
