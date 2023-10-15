# CMake code style

This repository adheres to established code style practices within the CMake
ecosystem.

* [1. Introduction](#1-introduction)
* [2. General guidelines](#2-general-guidelines)
  * [2.1. End commands](#21-end-commands)
* [3. Variables](#3-variables)
  * [3.1. Cache variables](#31-cache-variables)
  * [3.2. Directory variables](#32-directory-variables)
  * [3.3. Local variables](#33-local-variables)
  * [3.4. Find module variables](#34-find-module-variables)
  * [3.5. Variable names](#35-variable-names)
* [4. Modules](#4-modules)
  * [4.1. Find modules](#41-find-modules)
  * [4.2. Utility modules](#42-utility-modules)
* [5. Booleans](#5-booleans)
* [6. Functions and macros](#6-functions-and-macros)
* [7. Targets](#7-targets)
  * [7.1. Libraries and executables](#71-libraries-and-executables)
  * [7.2. Alias libraries](#72-alias-libraries)
  * [7.3. Custom targets](#73-custom-targets)
* [8. Determining platform](#8-determining-platform)
* [9. See also](#9-see-also)
  * [9.1. Tools](#91-tools)
    * [9.1.1. cmake-format (by cmakelang project)](#911-cmake-format-by-cmakelang-project)
    * [9.1.2. cmake-lint (by cmakelang project)](#912-cmake-lint-by-cmakelang-project)
    * [9.1.3. cmakelint](#913-cmakelint)
    * [9.1.4. bin/check-cmake.sh](#914-bincheck-cmakesh)
    * [9.1.5. cmake-format.json](#915-cmake-formatjson)
  * [9.2. Further resources](#92-further-resources)

## 1. Introduction

CMake is quite lenient regarding code style, but applying a certain framework
for writing CMake files can enhance both code quality and comprehension of the
build system, especially when multiple developers are involved. Consistency can
make it easier to manage and extend the build system in the future. Following
some naming conventions can maintain a clear and organized CMake project
structure while avoiding conflicts with external libraries and CMake scope.

For instance, it's important to note that CMake functions, macros, and commands
are not case-sensitive. In other words, the following two expressions are
equivalent:

```cmake
add_library(foo src.c)
```

```cmake
ADD_LIBRARY(foo src.c)
```

On the contrary, variable names are case-sensitive.

## 2. General guidelines

In most cases, the preferred style is to use **all lowercase letters**.

```cmake
add_library(foo src.c)

if(FOO)
  set(VAR "value")
endif()

target_include_directories(...)
```

### 2.1. End commands

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

## 3. Variables

CMake variables can be classified into various categories:

### 3.1. Cache variables

Cache variables are stored and persist across the entire build system. They
should be UPPER_CASE.

```cmake
# Cache variable
set(VAR <value> CACHE <type> "<help_text>")

# Cache variable as a boolean option
option(FOO "<help_text>" [value])
```

### 3.2. Directory variables

Directory variables are those within the scope of the current `CMakeLists.txt`
and its child directories. These should be UPPER_CASE.

```cmake
set(VAR <value>)
```

Since it's not possible to restrict the scope of such directory variables solely
to the current CMake file, it's customary to prefix them with an underscore
(`_`) and in lower_case to signify that they are intended for temporary use only
within the current file.

```cmake
set(_temporary_variable "Foo")
```

### 3.3. Local variables

Variables with a scope inside functions. These should be lower_case.

```cmake
function(foo)
  set(variable_name <value>)
  # ...
endfunction()
```

### 3.4. Find module variables

These are set and have scope of the directory when using the
`find_package(PackageName)` command. They are in form of
`<PackageName>_UPPER_CASE` where PackageName is of any case.

### 3.5. Variable names

* Variables named `_` can be used for values that are not important for code:

  ```cmake
  # For example, here only the matched value of CMAKE_MATCH_1 is important.
  string(REGEX MATCH "foo\\(([0-9]+)\\)" _ ${content})
  message(STATUS ${CMAKE_MATCH_1})
  ```

* Cache variables at the PHP level:

  These variables are designed to be adjusted by the user during the
  configuration phase, either through the command line or by using cmake-gui. It
  is recommended to prefix them with `PHP_` to facilitate their grouping within
  cmake-gui.

  ```cmake
  set(PHP_FOO_BAR <value>... CACHE <type> "<help_text>")
  option(PHP_ENABLE_FOO "<help_text>" [value])
  cmake_dependent_option(PHP_ENABLE_BAR "<help_text>" <value> <depends> <force>)
  ```

* Cache variables for PHP extensions:

  These variables follow a similar pattern to PHP level variables, but they are
  prefixed with `EXT_`. While it's a good practice to consider grouping these
  variables by the extension name for clarity, it's important to note that
  cmake-gui may not distinguish this subgrouping. Therefore, the decision to
  group them by extension name can be optional and context-dependent.

  ```cmake
  option(EXT_GD "<help_text>" [value])
  cmake_dependent_option(EXT_GD_AVIF "<help_text>" OFF "EXT_GD" OFF)
  ```

* Cache variables for Zend:

  These variables share the same characteristics as PHP level variables, but
  they are prefixed with `ZEND_`.

## 4. Modules

Modules are located in the `cmake/modules` directory.

### 4.1. Find modules

Find modules in this repository follow standard CMake naming conventions for
find modules. For example, find module `Find<PackageName>.cmake` can be loaded
by:

```cmake
find_package(PackageName)
```

It sets variable `<PackageName>_FOUND` and other optional variables, such as
`<PackageName>_VERSION`, `<PackageName>_INCLUDE_DIRS`, which are managed by
CMake's `FindPackageHandleStandardArgs`. Recommendation for find modules is that
they should expose imported targets, such as `PackageName::PackageName` which
can be then linked to a target in the project:

```cmake
find_package(PackageName)
target_link_libraries(php PRIVATE PackageName::PackageName)
```

`PackageName` can be in any case (a-zA-Z0-9), with PascalCase or package
original name case preferred.

### 4.2. Utility modules

Utility modules typically adhere to the `PascalCase.cmake` pattern. They are
prefixed with `PHP` by residing in the PHP directory (`cmake/modules/PHP`) and
can be included like this:

```cmake
include(PHP/PascalCase)
```

This approach is adopted for convenience to prevent any potential conflicts with
upstream CMake modules.

## 5. Booleans

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

## 6. Functions and macros

Functions are generally favored over macros due to their ability to establish
their own variable scope, unlike macros where variables remain visible in the
outer scope. Macros are primarily used in specific cases where setting variables
within the current scope of CMake code is required.

CMake function and macro names possess global scope, so it is recommended to
prefix them contextually, for example `php_`. It is preferred to adhere to the
snake_case style.

```cmake
function(php_function_name argument_name)
  # Function body
endfunction()

macro(php_macro_name)
  # Macro body
endmacro()
```

Similarly, like variables, functions and macros exclusively used within a single
CMake module or `CMakeLists.txt` file should be prefixed with an underscore
(`_`). This prefix serves as a signal to external code to refrain from using
them.

```cmake
function(_php_internal_function_name)
  # Function body
endfunction()
```

## 7. Targets

CMake targets are defined with `add_library()`, `add_executable()`, and
`add_custom_target()`. Target naming conventions in this repository are intended
to prevent clashes with existing system library names, especially when dealing
with libraries imported via `find_package()` or `FetchContent`.

### 7.1. Libraries and executables

Naming pattern when creating libraries and executables across the build system:

* `php_<sapi_name>`

  For targets associated with PHP SAPIs (Server APIs). Replace `<sapi_name>`
  with the specific PHP SAPI name.

* `php_<extension_name>`

  For targets associated with PHP extensions. Replace `<extension_name>` with
  the name of the PHP extension.

* `php_main`

  Target name of the PHP main binding.

* `php_tsrm`:

  Target name of the PHP thread-safe resource manager (TSRM).

* `zend`:

  Target name for the Zend engine.

Additionally, customizing the target output file name on the disk can be done by
setting target property `OUTPUT_NAME`.

```cmake
add_executable(php_<sapi_name> ...)
set_target_properties(php_<sapi_name> PROPERTIES OUTPUT_NAME php)
```

### 7.2. Alias libraries

To make it easier to work with these targets across the build system, it is
recommended to use alias libraries as linkable targets:

```cmake
# Creating a library for PHP extension
add_library(php_<extension_name> ...)

# Creating an alias for a PHP extension library
add_library(PHP::<extension_name> ALIAS php_<extension_name>)

# Linking the main PHP target with the extension using the alias
target_link_library(php_main PRIVATE PHP::<extension_name>)
```

### 7.3. Custom targets

Custom targets should be defined with clear names that indicate their purpose,
such as `php_generate_something`. These targets can be customized to perform
specific actions during the build process. They should be prefixed with the
target context. For example, `php_`, `php_<extension_name>_`, or `zend_`.

```cmake
add_custom_target(php_generate_something ...)
```

## 8. Determining platform

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

## 9. See also

### 9.1. Tools

Several tools for formatting and linting CMake files are available, and while
their maintenance status may vary, they can still prove valuable.

#### 9.1.1. cmake-format (by cmakelang project)

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

#### 9.1.2. cmake-lint (by cmakelang project)

The [`cmake-lint`](https://cmake-format.readthedocs.io/en/latest/cmake-lint.html)
tool is part of the cmakelang project and can help with linting CMake files:

```sh
cmake-lint <cmake/CMakeLists.txt cmake/...>
```

This tool can also utilize the `cmake-format.[json|py|yaml]` file using the `-c`
option.

#### 9.1.3. cmakelint

For linting there is also a separate and useful
[cmakelint](https://github.com/cmake-lint/cmake-lint) tool which similarly lints
and helps to better structure CMake files:

```sh
cmakelint <cmake/CMakeLists.txt cmake/...>
```

#### 9.1.4. bin/check-cmake.sh

For convenience there is a custom helper script added to this repository that
checks CMake files:

```sh
./bin/check-cmake.sh
```

#### 9.1.5. cmake-format.json

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

### 9.2. Further resources

* [CMake developers docs](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html)
