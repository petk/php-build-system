# CMake code style

This repository adheres to established code style practices within the CMake
ecosystem.

## Index

* [1. Introduction](#1-introduction)
* [2. General guidelines](#2-general-guidelines)
  * [2.1. End commands](#21-end-commands)
  * [2.2. Source and binary directories](#22-source-and-binary-directories)
  * [2.3. Determining platform](#23-determining-platform)
* [3. Variables](#3-variables)
  * [3.1. Variable scope](#31-variable-scope)
    * [3.1.1. Local variables](#311-local-variables)
    * [3.1.2. Directory variables](#312-directory-variables)
    * [3.1.3. Cache variables](#313-cache-variables)
  * [3.2. Naming variables](#32-naming-variables)
    * [3.2.1. Cache variables](#321-cache-variables)
    * [3.2.2. Find module variables](#322-find-module-variables)
    * [3.2.3. Temporary variables](#323-temporary-variables)
  * [3.3. Setting and unsetting variables](#33-setting-and-unsetting-variables)
* [4. Modules](#4-modules)
  * [4.1. Find modules](#41-find-modules)
  * [4.2. Utility modules](#42-utility-modules)
* [5. Booleans](#5-booleans)
* [6. Functions and macros](#6-functions-and-macros)
* [7. Targets](#7-targets)
  * [7.1. Libraries and executables](#71-libraries-and-executables)
  * [7.2. Alias targets](#72-alias-targets)
  * [7.3. Custom targets](#73-custom-targets)
* [8. Properties](#8-properties)
* [9. Installation components](#9-installation-components)
* [10. Tests](#10-tests)
* [11. See also](#11-see-also)
  * [11.1. Tools](#111-tools)
    * [11.1.1. Gersemi](#1111-gersemi)
    * [11.1.2. cmake-format (by cmakelang project)](#1112-cmake-format-by-cmakelang-project)
    * [11.1.3. cmake-lint (by cmakelang project)](#1113-cmake-lint-by-cmakelang-project)
    * [11.1.4. cmakelint](#1114-cmakelint)
  * [11.2. Further resources](#112-further-resources)

## 1. Introduction

CMake is quite lenient regarding code style, but applying consistency for
writing CMake files can enhance both code quality and comprehension of the build
system, especially when multiple developers are involved. Following some coding
conventions can maintain a clear and organized CMake project structure while
avoiding conflicts with external libraries and CMake scope.

For instance, it's important to note that CMake commands (functions, macros) are
not case sensitive. In other words, the following two expressions are
equivalent:

```cmake
add_library(foo src.c)
```

```cmake
ADD_LIBRARY(foo src.c)
```

On the contrary, variable names are case sensitive:

```cmake
set(variable_name "value")
```

```cmake
set(VARIABLE_NAME "value")
```

## 2. General guidelines

* In most cases, the preferred style is to use **all lowercase letters**.

  ```cmake
  add_library(php_foo src.c)

  function(php_function_name argument_name another_argument)
    if(argument_name)
      set(variable_name "value")
    endif()

    # ...
  endfunction()

  target_include_directories(...)
  ```

* During development check that variables are properly initialized and used to
  avoid unexpected behavior and errors in the build process:

  ```sh
  cmake --warn-uninitialized -S <source-directory> -B <build-directory>
  ```

* Long strings can be split into multiple lines by using line continuation with
  a backslash character (`\`) followed by a new line:

  ```cmake
  message(STATUS "\
  This string is concatenated \
  to a single line.\
  ")

  # Output: This string is concatenated to a single line.
  ```

* When defining path variables, exclude the trailing directory delimiter (`/`).
  This practice facilitates concatenation of such variables:

  ```cmake
  set(parent_dir "foo/bar")
  set(child_dir "${parentDir}/baz")
  ```

> [!TIP]
> Code strings or regular expressions, can alternatively be passed as bracket
> arguments (`[[`, `]]`, `[=[`, `]=]`, `[==[`, `]==]`, etc), helping to avoid
> the need for escaping characters:
>
> ```cmake
> install(CODE [[
>   execute_process(
>     COMMAND ${CMAKE_COMMAND} -E echo "${variable} references aren't evaluated"
>   )
>   set(version "1.2")
>   if(version MATCHES [=[^[0-9]\.[0-9]$]=])
>     message(STATUS "Nested bracket argument with varying '=' characters")
>   endif()
> ]])
> ```

### 2.1. End commands

To make the code easier to read, use empty commands for `else()`, `endif()`,
`endforeach()`, `endwhile()`, `endfunction()`, and `endmacro()`. The optional
legacy argument in these commands is not recommended anymore.

For example, do this:

```cmake
if(foo)
  # ...
else()
  # ...
endif()
```

and not this:

```cmake
if(foo)
  # ...
else(foo)
  # ...
endif(foo)
```

### 2.2. Source and binary directories

The variable `CMAKE_SOURCE_DIR` represents the top level project source code
directory, housing C and CMake files. Conversely, `CMAKE_BINARY_DIR` signifies
the *binary* (also called *build*) directory where built artifacts are output.

```sh
cmake -S <source-directory> -B <binary-directory>
```

For enhanced project portability, it is recommended to use `PROJECT_SOURCE_DIR`
and `PROJECT_BINARY_DIR`, or `<ProjectName>_SOURCE_DIR` and
`<ProjectName>_BINARY_DIR`, over `CMAKE_SOURCE_DIR` and `CMAKE_BINARY_DIR`.

For example, instead of:

```cmake
set(some_path ${CMAKE_SOURCE_DIR}/main/php_config.h)
```

use:

```cmake
set(some_path ${PROJECT_SOURCE_DIR}/file.h)
# and
set(some_path ${PHP_SOURCE_DIR}/main/php_config.h)
```

These variables succinctly define the root directories of the project, ensuring
consistency and ease of integration when employed in CMake files. In case of a
single CMake `project()` usage, there isn't any difference between `CMAKE_*_DIR`
or `PROJECT_*_DIR`. However, when multiple `project()` invocations occur, and
project directories are added via `add_subdirectory()` or external inclusions,
these variables become distinct.

* `CMAKE_SOURCE_DIR` and `CMAKE_BINARY_DIR`: Denote the project source and build
  directories from the first `project()` call in the root `CMakeLists.txt`.
* `PROJECT_SOURCE_DIR` and `PROJECT_BINARY_DIR`: Denote the project source and
  build directories from the most recent `project()` call.
* `<ProjectName>_SOURCE_DIR` and `<ProjectName>_BINARY_DIR` represent the
  project source and build directories from the most recent
  `project(ProjectName ...)` call.

### 2.3. Determining platform

CMake provides variables such as `APPLE`, `LINUX`, `UNIX`, `WIN32`, etc, for the
target systems, and `CMAKE_HOST_APPLE`, `CMAKE_HOST_LINUX`, etc, for the host
systems. To be more specific, the target and host platform can be also
determined by the:

* `CMAKE_SYSTEM_NAME` variable or the `PLATFORM_ID` generator expression to
  identify the target platform (which is also the name used during
  cross-compilation).
* `CMAKE_HOST_SYSTEM_NAME` variable to identify the platform where CMake is
  performing the build.

When building on the platform for which the build is targeted,
`CMAKE_SYSTEM_NAME` and `CMAKE_HOST_SYSTEM_NAME` are equivalent.

For example, detecting Linux target system:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  # ...
endif()
```

In generator expressions, `PLATFORM_ID` can be used to detect target platforms:

```cmake
target_compile_definitions(php PRIVATE $<$<PLATFORM_ID:Linux,FreeBSD>:FOOBAR>)
```

> [!NOTE]
> All values known to CMake for `CMAKE_SYSTEM_NAME`, `CMAKE_HOST_SYSTEM_NAME`,
> and `PLATFORM_ID` are listed in the
> [CMake documentation](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html).

To determine the target processor use the
[`CMAKE_C_COMPILER_ARCHITECTURE_ID`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ARCHITECTURE_ID.html)
variable. For example:

```cmake
if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(x86_64|x64)")
  # Target CPU is 64-bit x86.
endif()
```

## 3. Variables

### 3.1. Variable scope

CMake variables can be categorized based on their scope, which helps organize
and manage them effectively within the project.

#### 3.1.1. Local variables

Variables with a scope inside functions and blocks. These should preferably be
in *snake_case*.

```cmake
function(foo)
  set(variable_name <value>)
  # ...
endfunction()
```

The `block()` command can be used to restrict the variable scope to a specific
block of code:

```cmake
block()
  set(bar <value>)
  # ...
endblock()
```

Variable `bar` in the above example is uninitialized beyond the block's scope.

#### 3.1.2. Directory variables

Directory variables are those confined to the current `CMakeLists.txt` and its
child directories. To distinguish them, these variables should be in
*UPPER_CASE*.

```cmake
set(VARIABLE_NAME <value>)
```

This naming convention helps identify the variables that pertain to the current
directory and its descendants.

#### 3.1.3. Cache variables

Cache variables are stored and persist across the entire build system. They
should be *UPPER_CASE*.

```cmake
# Cache variable
set(CACHE{PHP_VAR} TYPE <type> HELP <help> VALUE <value>)

# Cache variable as a boolean option
option(PHP_FOO "<help>" [value])

# Cache variables created by CMake command invocations. For example
find_program(PHP_SED_EXECUTABLE NAMES sed)
```

### 3.2. Naming variables

When naming variables, it is considered good practice to restrict their names to
alphanumeric characters and underscores, enhancing readability.

Variables prefixed with `CMAKE_`, `_CMAKE_`, and `_<any-cmake-command-name>` are
reserved for CMake's internal use.

#### 3.2.1. Cache variables

Cache variables, either internal ones, or those designed to be adjusted by the
user during the configuration phase, for example, through the presets, command
line, or by using GUI, such as `cmake-gui` or `ccmake`, are recommended to be
prefixed with `PHP_` to facilitate their grouping within the GUI or IDE.

```cmake
option(PHP_ENABLE_FOO "<help>" [value])

cmake_dependent_option(PHP_ENABLE_BAR "<help>" <value> <depends> <force>)

set(CACHE{PHP_FOO_BAR} TYPE <type> HELP <help> VALUE <value>)

# Zend Engine configuration variables
option(PHP_ZEND_ENABLE_FOO "<help>" [value])

# Configuration variables related to PHP extensions
option(PHP_EXT_FOO "<help>" [value])

# Configuration variables related to PHP SAPI modules
option(PHP_SAPI_FOO "<help>" [value])
```

#### 3.2.2. Find module variables

Find module variables are established and confined to the directory scope when
employing the `find_package(PackageName)` command. These variables are
structured as `<PackageName>_UPPER_CASE`, with `PackageName` capable of being in
any case.

#### 3.2.3. Temporary variables

It's customary to prefix temporary variables that are intended for use within a
specific code block with an underscore (`_`). This naming convention indicates
that these variables are meant exclusively for internal use within the current
CMake file and should not be accessed outside of that context.

```cmake
set(_temporary_variable <value>)
```

> [!TIP]
> Variables named `_` can be used for values that are not important for code.
> For example, here only the matched value of variable `CMAKE_MATCH_1` is
> important, while variable `_` is used as a container for `string()` command
> argument and not used in the code later on:
>
> ```cmake
> string(REGEX MATCH "foo\\(([0-9]+)\\)" _ "${content}")
> message(STATUS "${CMAKE_MATCH_1}")
> ```

### 3.3. Setting and unsetting variables

In CMake, it's common practice to *reset* local variables within a specific
scope to avoid unintended use of previous values. When ensuring a variable is
empty before use, explicitly set it to an empty string:

```cmake
set(some_variable "")
```

Avoid this approach:

```cmake
set(some_variable)
# or
unset(some_variable)
```

The latter is equivalent to `unset(some_variable)`, which can unintentionally
expose a cache variable with the same name if it exists. For example:

```cmake
set(CACHE{some_variable} TYPE INTERNAL HELP "Some cache variable" VALUE "Foo")
# ...
set(some_variable)
message(STATUS "${some_variable}")
# Outputs: Foo
```

Setting the variable to an empty string ensures it is safely initialized without
interference from cache variables.

## 4. Modules

CMake modules are located in the `cmake/modules` directory.

### 4.1. Find modules

Find modules in this repository follow standard CMake naming conventions for
find modules. For example, find module `Find<PackageName>.cmake` can be loaded
by:

```cmake
find_package(PackageName)
```

This sets variable `<PackageName>_FOUND` variable, which is managed by the
CMake's
[FindPackageHandleStandardArgs](https://cmake.org/cmake/help/latest/module/FindPackageHandleStandardArgs.html)
module. Find modules should expose imported targets, such as
`PackageName::PackageName` which can be then linked to a target in the project:

```cmake
find_package(PackageName)
target_link_libraries(php PRIVATE PackageName::PackageName)
```

`PackageName` can be in any case (a-zA-Z0-9_), with *PascalCase* or package
upstream name case preferred.

### 4.2. Utility modules

Utility modules typically adhere to the `PascalCase.cmake` pattern. They are
prefixed with `PHP` by residing in the PHP directory (`cmake/modules/PHP`) and
can be included like this:

```cmake
include(PHP/PascalCase)
```

This approach is adopted for convenience to prevent any potential conflicts with
upstream CMake modules.

> [!TIP]
> When `CMakeLists.txt` becomes too complex for all-in-one configuration file,
> some PHP extensions, SAPIs and Zend Engine include configure checks from local
> modules located in their `cmake` subdirectories for simplicity.

## 5. Booleans

CMake interprets `1`, `ON`, `YES`, `TRUE`, and `Y` as representing boolean true
values, while `0`, `OFF`, `NO`, `FALSE`, `N`, `IGNORE`, `NOTFOUND`, an empty
string, or any value ending with the suffix `-NOTFOUND` are considered boolean
false values. Named boolean constants are case insensitive (e.g., `on`, `Off`,
`True`).

A general convention is to use `ON` and `OFF` for boolean values that can be
modified by the user, and `TRUE` and `FALSE` for intrinsic values that cannot or
should not be modified externally. For example:

```cmake
# Boolean variables that can be modified by the user use ON/OFF values
option(PHP_FOO "<help>" ON)

# The IMPORTED property is set to TRUE and cannot be modified after being set
add_library(php_foo UNKNOWN IMPORTED)
get_target_property(value php_foo IMPORTED)
message(STATUS "value=${value}")
# Outputs: value=TRUE

# Similarly, intrinsic values in the code use TRUE/FALSE
set(HAVE_FOO TRUE)
```

## 6. Functions and macros

Functions are generally favored over macros due to their ability to establish
their own variable scope, unlike macros where variables remain visible in the
outer scope. Macros are primarily used in specific cases where setting variables
within the current scope of CMake code is required.

CMake function and macro names possess global scope, so it is recommended to
prefix them contextually, for example `php_`. It is preferred to adhere to the
*snake_case* style.

```cmake
function(php_function_name argument_name)
  # Function body
endfunction()

macro(php_macro_name argument_name)
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
with libraries imported with `find_package()` command or `FetchContent` module.

### 7.1. Libraries and executables

Naming pattern when creating libraries and executables across the build system:

* `php_ext_<extension_name>`

  Targets associated with PHP extensions. Replace `<extension_name>` with the
  name of the PHP extension.

* `php_sapi_<sapi_name>`

  Targets associated with PHP SAPIs (PHP Server APIs). Replace `<sapi_name>`
  with the name of the PHP SAPI.

* `php_main`

  Target name of the PHP main binding.

* `php_zend` and `php_zend_*`:

  Targets associated with the Zend Engine.

Additionally, customizing the target output file name on the disk can be done by
setting target property `OUTPUT_NAME`.

```cmake
add_executable(php_sapi_<sapi_name> ...)
set_target_properties(php_sapi_<sapi_name> PROPERTIES OUTPUT_NAME php)
```

### 7.2. Alias targets

To make it easier to work with targets across the build system, it is
recommended to use aliases as linkable targets:

```cmake
# Creating a library
add_library(php_<target_name> ...)

# Creating an alias target for a library
add_library(PHP::<component_name> ALIAS php_<target_name>)

# Linking target using the alias
target_link_library(php_some_target PRIVATE PHP::<component_name>)
```

Using alias targets can have a performance and distinct benefit because whenever
CMake sees a double colon (`::`) in the target name, it will limit the search to
CMake targets only, unlike other naming patterns where CMake will search for
link flags, paths, or library names as well.

> [!TIP]
> PHP extensions and SAPIs use nested namespaces for their distinct convenience.
> However, CMake does not differentiate these from single-level namespaces.
>
> ```cmake
> # PHP extensions:
> add_library(php_ext_bcmath)
> add_library(PHP::ext::bcmath ALIAS php_ext_bcmath)
>
> PHP SAPIs:
> add_executable(php_sapi_cli)
> add_executable(PHP::sapi::cli ALIAS php_sapi_cli)
> ```

### 7.3. Custom targets

Custom targets should be defined with clear names that indicate their purpose,
such as `php_generate_something`. These targets can be customized to perform
specific actions during the build process. They should be prefixed with the
target context. For example, `php_`, `php_ext_<extension_name>_`,
`php_sapi_<sapi_name>_`, `php_zend_`, or similar.

```cmake
add_custom_target(php_generate_something ...)
```

## 8. Properties

In this repository, CMake custom properties follow the *UPPER_CASE* naming
convention and are consistently prefixed with a context-specific identifier,
such as `PHP_`.

```cmake
define_property(<scope> PROPERTY PHP_CUSTOM_PROPERTY_NAME [...])
```

## 9. Installation components

Installation components should follow the *kebab-case* naming convention and
they should be prefixed with `php-`:

```cmake
install(
  TARGETS php_foo_bar
  # ...
  COMPONENT php-foo-bar
)
```

## 10. Tests

Test names added with `add_test()` command should follow the *PascalCase* naming
convention and should be prefixed with `Php`:

```cmake
add_test(NAME PhpRunTests COMMAND ...)
add_test(NAME PhpSapiEmbedSharedBasic COMMAND ...)
add_test(NAME PhpUnitTest COMMAND ...)
```

## 11. See also

### 11.1. Tools

There are some tools available for formatting and linting CMake files. While
these tools can offer valuable assistance, it's worth emphasizing that the
current recommendation is generally not to rely on any specific linting tool.
This is primarily due to their varying levels of utility and a lack of updates
to keep pace with new CMake versions. It's worth mentioning that this
recommendation may evolve in the future as these tools continue to develop.

#### 11.1.1. Gersemi

The [`gersemi`](https://github.com/BlankSpruce/gersemi) tool can check and fix
CMake code style:

```sh
gersemi --check --indent 2 --diff --definitions cmake -- cmake
```

#### 11.1.2. cmake-format (by cmakelang project)

The [`cmake-format`](https://cmake-format.readthedocs.io/en/latest/) tool can
find formatting issues and sync the CMake code style:

```sh
cmake-format --check <CMakeLists.txt cmake/...>
```

It can utilize the configuration file (default `cmake-format.[json|py|yaml]`) or
by passing the `--config-files` or `-c` option:

```sh
cmake-format -c path/to/cmake-format.json --check -- <CMakeLists.txt cmake/...>
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

#### 11.1.3. cmake-lint (by cmakelang project)

The [`cmake-lint`](https://cmake-format.readthedocs.io/en/latest/cmake-lint.html)
tool is part of the cmakelang project and can help with linting CMake files:

```sh
cmake-lint <CMakeLists.txt cmake/...>
```

This tool can also utilize the `cmake-format.[json|py|yaml]` file using the `-c`
option.

#### 11.1.4. cmakelint

For linting there is also a separate and useful
[cmakelint](https://github.com/cmake-lint/cmake-lint) tool which similarly lints
and helps to better structure CMake files:

```sh
cmakelint <cmake/CMakeLists.txt cmake/...>
```

### 11.2. Further resources

* [CMake developers docs](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html)
* [CMake documentation guide](https://gitlab.kitware.com/cmake/cmake/-/blob/master/Help/dev/documentation.rst)
