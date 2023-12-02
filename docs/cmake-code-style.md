# CMake code style

This repository adheres to established code style practices within the CMake
ecosystem.

* [1. Introduction](#1-introduction)
* [2. General guidelines](#2-general-guidelines)
  * [2.1. End commands](#21-end-commands)
  * [2.2. Source and binary directories](#22-source-and-binary-directories)
* [3. Variables](#3-variables)
  * [3.1. Variable scope](#31-variable-scope)
    * [3.1.1. Local variables](#311-local-variables)
    * [3.1.2. Directory variables](#312-directory-variables)
    * [3.1.3. Cache variables](#313-cache-variables)
  * [3.2. Naming variables](#32-naming-variables)
    * [3.2.1. Configuration variables](#321-configuration-variables)
    * [3.2.2. Find module variables](#322-find-module-variables)
    * [3.2.3. Temporary variables](#323-temporary-variables)
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
* [9. Determining platform](#9-determining-platform)
  * [9.1. Determining processor](#91-determining-processor)
* [10. See also](#10-see-also)
  * [10.1. Tools](#101-tools)
    * [10.1.1. cmake-format (by cmakelang project)](#1011-cmake-format-by-cmakelang-project)
    * [10.1.2. cmake-lint (by cmakelang project)](#1012-cmake-lint-by-cmakelang-project)
    * [10.1.3. cmakelint](#1013-cmakelint)
    * [10.1.4. bin/check-cmake.sh](#1014-bincheck-cmakesh)
    * [10.1.5. cmake-format.json](#1015-cmake-formatjson)
  * [10.2. Further resources](#102-further-resources)

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

* In most cases, the preferred style is to use **all lowercase letters**.

  ```cmake
  add_library(foo src.c)

  function(bar argument)
    if(argument)
      set(var "value")
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
  a backslash (`\`) character followed by a new line:

  ```cmake
  message("\
  This string is concatenated \
  to a single line.\
  ")
  ```

* When defining path variables, exclude the trailing directory delimiter `/`.
  This practice facilitates concatenation of such variables:

  ```cmake
  set(parent_dir "foo/bar")
  set(child_dir "${parent_dir}/baz")
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

### 2.2. Source and binary directories

The variable `CMAKE_SOURCE_DIR` represents the project's root source code
directory, housing C and CMake files. Conversely, `CMAKE_BINARY_DIR` signifies
the binary (also called build) directory where build artifacts are output.

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

* `CMAKE_SOURCE_DIR`: Denotes the source directory of the project from the first
  `project()` call in the root `CMakeLists.txt`.
* `CMAKE_BINARY_DIR`: Denotes the build directory of the project from the first
  `project()` call in the root `CMakeLists.txt`.
* `PROJECT_SOURCE_DIR`: Denotes the source directory of the project from the
  most recent `project()` call in the subdirectory `CMakeLists.txt`.
* `PROJECT_BINARY_DIR`: Denotes the build directory of the project from the most
  recent `project()` call in the subdirectory `CMakeLists.txt`.
* `<ProjectName>_SOURCE_DIR` and `<ProjectName>_BINARY_DIR` represent the
  source and build directories of the project from the `CMakeLists.txt` with
  `project(ProjectName ...)`.

## 3. Variables

### 3.1. Variable scope

CMake variables can be categorized based on their scope, which helps organize
and manage them effectively within the project.

#### 3.1.1. Local variables

Variables with a scope inside functions and blocks. These should be lower_case.

```cmake
function(foo)
  set(variable_name <value>)
  # ...
endfunction()
```

The `block()` command can be used to restrict the variable scope to a specific
block of code:

```cmake
block(SCOPE_FOR VARIABLES)
  set(bar <value>)

  # <commands>...
endblock()
```

Variable `bar` in the above example is uninitialized beyond the block's scope.

#### 3.1.2. Directory variables

Directory variables are those confined to the current `CMakeLists.txt` and its
child directories. To distinguish them, these variables should be in UPPER_CASE.

```cmake
set(VAR <value>)
```

This naming convention helps identify the variables that pertain to the current
directory and its descendants.

#### 3.1.3. Cache variables

Cache variables are stored and persist across the entire build system. They
should be UPPER_CASE.

```cmake
# Cache variable
set(VAR <value> CACHE <type> "<help_text>")

# Cache variable as a boolean option
option(FOO "<help_text>" [value])

# Cache variables created by CMake command invocations. For example
find_program(RE2C_EXECUTABLE re2c)
```

### 3.2. Naming variables

When naming variables, it is considered good practice to restrict their names to
alphanumeric characters and underscores, enhancing readability.

Variables prefixed with `CMAKE_`, `_CMAKE_`, and `_<any-cmake-command-name>` are
reserved for CMake's internal use.

#### 3.2.1. Configuration variables

Configuration variables are cache variables designed to be adjusted by the user
during the configuration phase, either through the presets, command line, or by
using GUI, such as cmake-gui or ccmake. It is recommended to prefix them with
`PHP_`, `ZEND_`, `EXT_`, and similar to facilitate their grouping within the
GUI.

```cmake
# PHP configuration variables
set(PHP_FOO_BAR <value>... CACHE <BOOL|FILEPATH|PATH|STRING> "<help_text>")
option(PHP_ENABLE_FOO "<help_text>" [value])
cmake_dependent_option(PHP_ENABLE_BAR "<help_text>" <value> <depends> <force>)

# Zend engine configuration variables
option(ZEND_ENABLE_FOO "<help_text>" [value])

# Configuration variables related to PHP extensions
option(EXT_FOO "<help_text>" [value])
```

While it's a good practice to consider grouping variables inside an extension by
the extension name for clarity (for example, `EXT_<extension>`,
`EXT_<extension>_FOO`), it's worth noting that GUI may not distinguish such
subgrouping. Therefore, the decision to additionally group them by the extension
name beside the primary prefix `EXT_` can be optional and context-dependent,
when the extension involves multiple options:

```cmake
option(EXT_GD "<help_text>" [value])
cmake_dependent_option(EXT_GD_AVIF "<help_text>" OFF "EXT_GD" OFF)
cmake_dependent_option(EXT_GD_WEBP "<help_text>" OFF "EXT_GD" OFF)
```

#### 3.2.2. Find module variables

Find module variables are established and confined to the directory scope when
employing the `find_package(PackageName)` command. These variables are
structured as `<PackageName>_UPPER_CASE`, with `PackageName` capable of being in
any case.

#### 3.2.3. Temporary variables

It's customary to prefix temporary variables that are intended for use within a
specific code block with an underscore (`_`) and write them in lower_case. This
naming convention indicates that these variables are meant exclusively for
internal use within the current CMake file and should not be accessed outside of
that context.

```cmake
set(_temporary_variable <value>)
```

Variables named `_` can be used for values that are not important for code:

```cmake
# For example, here only the matched value of CMAKE_MATCH_1 is important.
string(REGEX MATCH "foo\\(([0-9]+)\\)" _ "${content}")
message(STATUS "${CMAKE_MATCH_1}")
```

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
false values. Named boolean constants are case-insensitive.

To ensure compatibility with existing C code and the configuration header
`php_config.h`, some potential simplifications may be considered for this
repository:

```cmake
# Options have ON/OFF values.
option(FOO "<help_text>" ON)

# Conditional variables have 1/0 values.
set(HAVE_FOO_H 1 CACHE INTERNAL "<help_text>")

# Elsewhere in commands, functions etc. use TRUE/FALSE
set(CMAKE_C_STANDARD_REQUIRED TRUE)
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

### 7.3. Custom targets

Custom targets should be defined with clear names that indicate their purpose,
such as `php_generate_something`. These targets can be customized to perform
specific actions during the build process. They should be prefixed with the
target context. For example, `php_`, `php_<extension_name>_`, or `zend_`.

```cmake
add_custom_target(php_generate_something ...)
```

## 8. Properties

In this repository, CMake custom properties follow the UPPER_CASE naming
convention and are consistently prefixed with a context-specific identifier,
such as `PHP_`.

```cmake
define_property(<scope> PROPERTY PHP_CUSTOM_PROPERTY_NAME [...])
```

## 9. Determining platform

CMake offers variables such as `APPLE`, `LINUX`, `UNIX`, `WIN32` etc. However,
they might be removed in the future CMake versions. It is recommended to use:

* `CMAKE_SYSTEM_NAME` in code or `PLATFORM_ID` in generator expressions to check
  the target platform (which is also the name used during cross-compilation).
* And the `CMAKE_HOST_SYSTEM_NAME` to identify the platform where CMake is
  peforming the build.

When building on the platform for which the build is targeted,
`CMAKE_SYSTEM_NAME` and `CMAKE_HOST_SYSTEM_NAME` are equivalent.

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

In generator expressions, `PLATFORM_ID` can be used to detect target platforms:

```cmake
target_compile_definitions(
  php
  PRIVATE $<$<PLATFORM_ID:Linux,FreeBSD>:FOOBAR>
)
```

Some platforms require the regular expression matching. For example, checking if
the host system is Cygwin:

```cmake
if(CMAKE_HOST_SYSTEM_NAME MATCHES "CYGWIN.*")
  # ...
endif()
```

See also [CMakeDetermineSystem.cmake](https://gitlab.kitware.com/cmake/cmake/-/blob/master/Modules/CMakeDetermineSystem.cmake).

### 9.1. Determining processor

When cross compiling the `CMAKE_SYSTEM_PROCESSOR` is determined from the
toolchain file. When compiling on the machine for which the build is also
targeted, the `CMAKE_SYSTEM_PROCESSOR` and `CMAKE_HOST_SYSTEM_PROCESSOR` will be
the same.

Processor is determined by various ways depending on the system.

Some examples:

* On FreeBSD the `x86_64` is detected as `amd64`:

  ```cmake
  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
    # CPU is x86_64.
  endif()
  ```

* The `aarch64` or `aarch64_be`:

  ```cmake
  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^aarch64.*")
    # CPU is aarch64.
  endif()
  ```

* `sparc`, `sparc64`

## 10. See also

### 10.1. Tools

There are several tools available for formatting and linting CMake files, each
with varying levels of maintenance and utility. While these tools can offer
valuable assistance, it's worth emphasizing that the current recommendation is
generally not to rely on any specific linting tool. This is primarily due to
their varying levels of maturity and a lack of updates to keep pace with new
CMake versions. It's worth mentioning that this recommendation may evolve in the
future as these tools continue to develop and adapt.

#### 10.1.1. cmake-format (by cmakelang project)

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

#### 10.1.2. cmake-lint (by cmakelang project)

The [`cmake-lint`](https://cmake-format.readthedocs.io/en/latest/cmake-lint.html)
tool is part of the cmakelang project and can help with linting CMake files:

```sh
cmake-lint <cmake/CMakeLists.txt cmake/...>
```

This tool can also utilize the `cmake-format.[json|py|yaml]` file using the `-c`
option.

#### 10.1.3. cmakelint

For linting there is also a separate and useful
[cmakelint](https://github.com/cmake-lint/cmake-lint) tool which similarly lints
and helps to better structure CMake files:

```sh
cmakelint <cmake/CMakeLists.txt cmake/...>
```

#### 10.1.4. bin/check-cmake.sh

For convenience there is a custom helper script added to this repository that
checks CMake files:

```sh
./bin/check-cmake.sh
```

#### 10.1.5. cmake-format.json

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

### 10.2. Further resources

* [CMake developers docs](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html)
