# Quick introduction to CMake

This is a simple introduction to the CMake build system in general, aimed at
providing a basic understanding of its fundamentals.

* [1. Command line usage](#1-command-line-usage)
  * [1.1. Configuration and generation phase](#11-configuration-and-generation-phase)
  * [1.2. Build phase](#12-build-phase)
  * [1.3. In-source builds](#13-in-source-builds)
* [2. CMakeLists.txt](#2-cmakeliststxt)
  * [2.1. Including other CMake files](#21-including-other-cmake-files)
  * [2.2. Defining targets](#22-defining-targets)
  * [2.3. Working with targets](#23-working-with-targets)
* [3. Variables](#3-variables)
  * [3.1. Setting variables](#31-setting-variables)
  * [3.2. Working with cache variables](#32-working-with-cache-variables)
  * [3.3. Using variables](#33-using-variables)
  * [3.4. Lists](#34-lists)
* [4. Verification and checks in CMake](#4-verification-and-checks-in-cmake)
  * [4.1. Header availability check](#41-header-availability-check)
  * [4.2. C source compilation check](#42-c-source-compilation-check)
  * [4.3. C source compilation and execution check](#43-c-source-compilation-and-execution-check)
  * [4.4. Cross-compilation considerations](#44-cross-compilation-considerations)
* [5. Generating a configuration header](#5-generating-a-configuration-header)
* [6. Further resources](#6-further-resources)

## 1. Command line usage

When working with CMake, there are two primary phases: the configuration and
generation phase, followed by the build phase.

### 1.1. Configuration and generation phase

In this phase, CMake performs essential tasks to set up a build environment:

```sh
# Generating build system from a source directory to a build directory:
cmake -S source-directory -B build-directory
```

During this process, CMake reads `CMakeLists.txt` source files, configures the
build system (including configuration headers), and generates necessary build
system files like Makefiles.

### 1.2. Build phase

The build phase is where C/C++ project source files are built to libraries and
executables:

```sh
# Build the project from the specified build directory:
cmake --build build-directory --parallel
```

In this phase, project is compiled and assembled, making it ready for execution.
The `--parallel` option enables parallel build processes for faster compilation.

### 1.3. In-source builds

For in-source builds (when source and build directories are the same):

```sh
cmake .
cmake --build . --parallel
```

## 2. CMakeLists.txt

In the world of CMake, the `CMakeLists.txt` files serve as blueprints for
configuring and building projects. These files define how the project source
code should be built into libraries and binaries.

### 2.1. Including other CMake files

To maintain modularity and organization, you can include other CMake files
within your project:

```cmake
# CmakeLists.txt

# Including CMake file using relative path
include(path/to/file.cmake)

# Including a CMake module
include(CheckCSourceCompiles)
```

This allows you to break down complex configurations into manageable components.

### 2.2. Defining targets

CMake revolves around targets, which represent various components of your
project. There are primarily two types: libraries and executables.

```cmake
# CMakeLists.txt

# Creating a library target (STATIC or SHARED)
add_library(main STATIC|SHARED src.c src_2.c)

# Creating an executable target
add_executable(php src.c src_2.c)
```

### 2.3. Working with targets

Once you've defined your targets, you can fine-tune them with additional
configurations:

```cmake
# CMakeLists.txt

# Adding more source files to a target
target_sources(php INTERFACE|PUBLIC|PRIVATE src_3.c)

# Specifying include directories for a target
target_include_directories(php INTERFACE|PUBLIC|PRIVATE include/1 include/2)

# Setting compile options for a target
target_compile_options(php INTERFACE|PUBLIC|PRIVATE -Wno-implicit-fallthrough)

# Linking libraries, flags, or another targets to a target
target_link_libraries(php INTERFACE|PUBLIC|PRIVATE main)
```

The keywords `INTERFACE`, `PUBLIC`, and `PRIVATE` exhibit similarities to the
visibility concept in object-oriented programming. When you use `PRIVATE`, it
signifies that an item is exclusively accessible to the defined target and is
not exposed to any depending targets. On the other hand, `PUBLIC` indicates that
the item is accessible both to the defined target and any depending targets.
Lastly, `INTERFACE` denotes that the item is solely accessible to depending
targets and is not accessible to the defining target itself.

## 3. Variables

In CMake, variables are essential for storing and manipulating data throughout
your project's configuration and build processes. They play a pivotal role in
customizing builds and managing project-specific settings.

### 3.1. Setting variables

Variables are set using the `set()` command, where you assign a value to a
variable:

```cmake
# A regular variable
set(VARIABLE "value")

# Cache variables are stored and persist across the entire build system
set(CACHE_VARIABLE "value" CACHE STRING "Documentation for this variable")
```

Cache variables, in particular, are noteworthy because they offer a means to
store values that remain consistent across different CMake runs and are
accessible to various parts of your project. You can even provide documentation
to describe the purpose of a cache variable.

### 3.2. Working with cache variables

Cache variables are highly versatile and can be influenced from various sources,
such as the command line. This allows for dynamic configuration adjustments:

```sh
# Passing a value to a cache variable via the command line
cmake -DCACHE_VARIABLE:STRING="value" -S source-directory -B build-directory
```

Cache variables become particularly useful for customizing builds, specifying
project-wide settings, and adapting configurations to different environments.

### 3.3. Using variables

Variable references in CMake use `$` sigil symbol and are enclosed within curly
brackets `{}`.

```cmake
set(VAR "value")
message(STATUS ${VAR})

# Output: value
```

Certain commands, such as `if()`, also support variable names:

```cmake
if(VAR STREQUAL "value")
  message(STATUS "Variable VAR is ${VAR}")
endif()

# Output: Variable VAR is value
```

### 3.4. Lists

Lists in CMake are strings separated with `;`.

```cmake
# Creating a list
set(list_variable a b c)

# Or
set(list_variable "a;b;c")

# This is a normal string, not a list
set(string_variable "a b c")
```

The `list()` command performs operations on lists.

## 4. Verification and checks in CMake

In CMake, you can perform various verification and validation tasks to ensure
the availability of headers, symbols, struct members, as well as assess the
compilation and execution of C code. These checks are crucial for configuring
your project correctly.

CMake provides a range of commands, many of which are found in separate CMake
modules bundled with CMake. These modules need to be included before utilizing
the respective verification commands:

### 4.1. Header availability check

To verify if a header file is available:

```cmake
include(CheckIncludeFile)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
```

### 4.2. C source compilation check

To determine if a C source file compiles and links into an executable:

```cmake
include(CheckCSourceCompiles)
check_c_source_compiles("int main(void) { return 0; }" HAVE_WORKING_HELLO_WORLD)
```

This command initiates a compilation and linking step, as illustrated here:

```sh
gcc -o out check_program.c
```

### 4.3. C source compilation and execution check

For a more comprehensive assessment that includes compiling, linking, and
executing the C code:

```cmake
include(CheckCSourceRuns)
check_c_source_runs("int main(void) { return 0; }" HAVE_WORKING_HELLO_WORLD)
```

This will compile, link and also run the program to check if the return code is
0:

```sh
gcc -o out check_program.c
./out
```

### 4.4. Cross-compilation considerations

Cross-compilation is a method where a project is compiled on one system but
targeted to run on another. In cross-compilation scenarios, running C test
programs isn't always feasible or guaranteed. Here's how to handle it:

```cmake
if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: Certain checks may not be applicable.")
else()
  check_c_source_runs("int main(void) { return 0; }" HAVE_WORKING_HELLO_WORLD)
endif()
```

## 5. Generating a configuration header

Once the necessary checks have been completed during the configuration phase,
you can proceed to create a configuration header file. This header file serves
as a configuration component in customizing your project's build based on the
check results, and it is generated using the `configure_file()` command.

```cmake
# Generating a header file from the config.h.in template
configure_file(
  ${CMAKE_SOURCE_DIR}/src/config.h.in
  ${CMAKE_BINARY_DIR}/src/config.h
)
```

The variable `CMAKE_SOURCE_DIR` represents the project's source directory, while
`CMAKE_BINARY_DIR` represents the build directory.

The `configure_file()` command reads a template file `src/config.h.in`, which
contains placeholders for variables and their associated values:

```c
/* src/config.h.in */

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H @HAVE_SYS_TYPES_H@
```

and replaces the placeholders in the template file with the actual values of the
corresponding variables. For example:

```c
/* src/config.h */

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1
```

This resulting `src/config.h` header file is used for directing the build system
and source code, as it defines preprocessor macros based on the configuration
results. It enables conditional compilation and helps ensure that your project
behaves correctly across various environments.

```c
/* src/main.c */

#include "config.h"

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif

int main(void) {
    return 0;
}
```

## 6. Further resources

A highly recommended starting point for learning CMake is the step-by-step
[tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html).

Additionally, there are several valuable CMake resources:

* [Official CMake documentation](https://cmake.org/documentation/): The official
  documentation offers comprehensive guidance on CMake's features and
  functionalities.
* [Effective Modern CMake](https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1):
  This resource provides insights into good practices for using CMake
  effectively.
* [Awesome CMake](https://github.com/onqtam/awesome-cmake): A curated list of
  CMake-related tools, libraries, and extensions, which might be useful for
  CMake projects.
