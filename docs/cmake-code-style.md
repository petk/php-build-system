# CMake code style

This repository adheres to established code style practices within the CMake
ecosystem.

* [1. Introduction](#1-introduction)
* [2. Code style](#2-code-style)
  * [2.1. General guidelines](#21-general-guidelines)
  * [2.2. Variable names](#22-variable-names)
  * [2.3. End commands](#23-end-commands)
  * [2.4. Module naming conventions](#24-module-naming-conventions)
  * [2.5. Booleans](#25-booleans)
  * [2.6. Functions and macros](#26-functions-and-macros)
  * [2.7. Determining platform](#27-determining-platform)
* [3. Tools](#3-tools)
  * [3.1. cmake-format (by cmakelang project)](#31-cmake-format-by-cmakelang-project)
  * [3.2. cmake-lint (by cmakelang project)](#32-cmake-lint-by-cmakelang-project)
  * [3.3. cmakelint](#33-cmakelint)
* [4. See also](#4-see-also)
  * [4.1. bin/check-cmake.sh](#41-bincheck-cmakesh)
  * [4.2. Customized rules for cmake-format and cmake-lint in cmake-format.json](#42-customized-rules-for-cmake-format-and-cmake-lint-in-cmake-formatjson)
  * [4.3. Further resources for CMake code style](#43-further-resources-for-cmake-code-style)

## 1. Introduction

CMake is quite lenient regarding code style, but applying a certain framework
for writing CMake files can enhance both code quality and comprehension of the
build system, especially when multiple developers are involved.

For instance, it's important to note that CMake functions, macros, and commands
are not case-sensitive. In other words, the following two expressions are
equivalent:

```cmake
add_library(foo foo.c bar.c)
```

```cmake
ADD_LIBRARY(foo foo.c bar.c)
```

On the contrary, variable names are case-sensitive.

## 2. Code style

### 2.1. General guidelines

* In most cases, the preferred style is to use **all lowercase letters**.

  ```cmake
  add_library(foo foo.c bar_baz.c)
  ```

### 2.2. Variable names

CMake variables can be classified into various categories:

* Cache internal variables

  ```cmake
  set(VAR <value> CACHE INTERNAL "<help_text>")
  ```

  These should be UPPER_CASE.

* Cache variables

  ```cmake
  set(VAR <value> CACHE <type> "<help_text>")
  option(FOO "<help_text>" [value])
  ```

  These should be UPPER_CASE.

* Local variables

  Variables with a scope inside functions. These should be lower_case.

  ```cmake
  function(foo)
    set(variable_name <value>)
    # ...
  endfunction()
  ```

* Directory variables

  Directory variables are those within the scope of the current `CMakeLists.txt`
  and its child directories with CMake files.

  If variable is meant to be used within other child directories these should
  be UPPER_CASE.

  Variables intended for use within the current CMake file and other directories
  should be UPPER_CASE.

  Since it's not possible to restrict the scope of these directory-specific
  variables solely to the current CMake file, it's customary to prefix them with
  an underscore (`_`) to signify that they are intended for temporary use only
  within the current file:

  ```cmake
  set(_temporary_variable "Foo")
  ```

* Variables named `_` can be used for values that are not important for code:

  ```cmake
  # For example, here only the matched value of CMAKE_MATCH_1 is important.
  string(REGEX MATCH "foo\\(([0-9]+)\\)" _ ${content})
  message(STATUS ${CMAKE_MATCH_1})
  ```

* Configuration variables at the PHP level:

  These variables are designed to be adjusted by the user during the
  configuration phase, either through the command line or by using cmake-gui. It
  is recommended to prefix them with `PHP_` to facilitate their grouping within
  cmake-gui.

  ```cmake
  set(PHP_FOO_BAR <value>... CACHE <type> "<help_text>")
  option(PHP_ENABLE_FOO "<help_text>" [value])
  cmake_dependent_option(PHP_ENABLE_BAR "<help_text>" <value> <depends> <force>)
  ```

* Configuration variables for PHP extensions:

  These variables follow a similar pattern to PHP configuration variables, but
  they are prefixed with `EXT_`. While it's a good practice to consider grouping
  these variables by the extension name for clarity, it's important to note that
  cmake-gui may not distinguish this subgrouping. Therefore, the decision to
  group them by extension name can be optional and context-dependent.

  ```cmake
  option(EXT_GD "<help_text>" [value])
  cmake_dependent_option(EXT_GD_AVIF "<help_text>" OFF "EXT_GD" OFF)
  ```

* Configuration variables for Zend:

  These variables share the same characteristics as PHP configuration variables,
  but they are prefixed with `ZEND_`.

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

Modules are located in the `cmake/modules` directory.

Naming convention for find modules is `FindUPPERCASE.cmake`.

```cmake
find_package(UPPERCASE)
```

Utility modules typically adhere to the `PascalCase.cmake` pattern. They are
prefixed with `PHP` by residing in the PHP directory and can be included like
this:

```cmake
include(PHP/PascalCase.cmake)
```

This approach is adopted for convenience to prevent any potential conflicts with
upstream CMake modules.

### 2.5. Booleans

CMake interprets `1`, `ON`, `YES`, `TRUE`, and `Y` as representing boolean true
values, while `0`, `OFF`, `NO`, `FALSE`, `N`, `IGNORE`, `NOTFOUND`, an empty
string, or a value ending with the suffix `-NOTFOUND` are considered as boolean
false values. It's important to note that these named constants are
case-insensitive.

To ensure compatibility with existing C code and the configuration header
`php_config.h`, some potential simplifications may be considered for this
repository:

```cmake
# Options have ON/OFF values.
option(FOO "<help_text>" ON)

# Conditional variables have 1/0 values.
set(HAVE_FOO_H 1 CACHE INTERNAL "<help_text>")

# Elsewhere in commands, functions etc. TRUE/FALSE.
```

### 2.6. Functions and macros

Functions are generally favored over macros due to their ability to establish
their own variable scope, while variables within macros remain visible from the
outer scope.

When naming functions, it is recommended to adhere to the snake_case style.

CMake functions possess global scope. Likewise, just like variables, functions
that are exclusively used within a single CMake module or `CMakeLists.txt` file
should be prefixed with an underscore (`_`). This prefix serves as a signal to
external code to refrain from using them.

### 2.7. Determining platform

CMake offers variables such as `APPLE`, `LINUX`, `UNIX`, `WIN32` etc. However,
they might be removed in the future CMake versions. Recommendation is to use:

* `CMAKE_SYSTEM_NAME` in code or `PLATFORM_ID` in generators for targeted
  platform (this is also the name of the target when doing cross-compilation).
* And the `CMAKE_HOST_SYSTEM_NAME` which is platform where CMake is building on.

For example, detecting Linux target system:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  # ...
endif()
```

Detecting Apple systems targets such as macOS, OS X etc.:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  # ...
endif()
```

Detecting Windows target:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # ...
endif()
```

See also [CMakeDetermineSystem.cmake](https://gitlab.kitware.com/cmake/cmake/-/blob/master/Modules/CMakeDetermineSystem.cmake).

## 3. Tools

Several tools for formatting and linting CMake files are available, and while
their maintenance status may vary, they can still prove valuable.

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
