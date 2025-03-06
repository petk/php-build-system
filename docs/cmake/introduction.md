# Introduction to CMake

This is a simple introduction to CMake in general, aimed at providing a basic
understanding of its fundamentals.

## Index

* [1. Introduction](#1-introduction)
* [2. Command-line usage](#2-command-line-usage)
  * [2.1. Configuration and generation phase](#21-configuration-and-generation-phase)
  * [2.2. Build phase](#22-build-phase)
* [3. CMakeLists.txt](#3-cmakeliststxt)
  * [3.1. Including other CMake files](#31-including-other-cmake-files)
* [4. CMake syntax](#4-cmake-syntax)
  * [4.1. Variables](#41-variables)
    * [4.1.1. Setting variables](#411-setting-variables)
    * [4.1.2. Working with cache variables](#412-working-with-cache-variables)
    * [4.1.3. Using variables](#413-using-variables)
    * [4.1.4. Lists](#414-lists)
  * [4.2. Functions](#42-functions)
  * [4.3. Arguments](#43-arguments)
    * [4.3.1. Quoted arguments](#431-quoted-arguments)
    * [4.3.2. Unquoted arguments](#432-unquoted-arguments)
    * [4.3.3. Bracket arguments](#433-bracket-arguments)
* [5. Targets](#5-targets)
  * [5.1. Executables](#51-executables)
  * [5.2. OBJECT library](#52-object-library)
  * [5.3. SHARED library](#53-shared-library)
  * [5.4. MODULE library](#54-module-library)
  * [5.5. STATIC library](#55-static-library)
  * [5.6. Working with targets](#56-working-with-targets)
* [6. Verification and checks in CMake](#6-verification-and-checks-in-cmake)
  * [6.1. Header availability check](#61-header-availability-check)
  * [6.2. C source compilation check](#62-c-source-compilation-check)
  * [6.3. C source compilation and execution check](#63-c-source-compilation-and-execution-check)
* [7. Generating a configuration header](#7-generating-a-configuration-header)
* [8. Where to go from here?](#8-where-to-go-from-here)

## 1. Introduction

[CMake](https://cmake.org/) is an open-source, cross-platform meta build system
created by Kitware and contributors. It's not a build system *per se*, but
rather a build system generator that produces configuration files for specific
build systems, such as Unix Makefiles, Visual Studio projects, or Ninja build
files.

## 2. Command-line usage

CMake is typically invoked from the command line using the `cmake` command. When
working with CMake, there are two primary phases: the configuration and
generation phase, where CMake sets up the project's build files, and the build
phase, where the target build system compiles the project.

### 2.1. Configuration and generation phase

In this phase, CMake performs essential tasks to set up a build environment. It
reads source files (`CMakeLists.txt`) from the source directory, configures the
build system, and generates the necessary build system files, such as Makefiles,
into a build directory.

```sh
# Generate build system from a source directory to a build directory
cmake -S source-directory -B build-directory
```

### 2.2. Build phase

The build phase involves transforming project C/C++ source files into libraries
and executables. During this phase, the project undergoes compilation and
assembly, preparing it for execution. The `--parallel` option (or short `-j`)
enables concurrent build processes for faster compilation.

```sh
# Build the project from the specified build directory
cmake --build build-directory --parallel
```

> [!NOTE]
> So-called **in-source builds** are a simplification when building inside a
> source directory (when source and build directories are the same):
>
> ```sh
> cmake .  # Same as: cmake -S . -B .
> cmake --build . --parallel
> ```
>
> The build system generates multiple files not intended to be tracked by Git.
> Therefore, it is recommended to establish a distinct build directory right
> from the start. For instance, a build directory can be also created within the
> source directory:
>
> ```sh
> cmake -B build-directory
> cmake --build build-directory --parallel
> ```

## 3. CMakeLists.txt

In the world of CMake, the `CMakeLists.txt` files serve as blueprints for
configuring and building projects. These files define how the project source
code should be built into libraries and executables.

```cmake
# CMakeLists.txt

# Require a minimum CMake version to build the project
cmake_minimum_required(VERSION 3.25)

# Set the project name and metadata
project(SomeProjectName VERSION 1.0.0 LANGUAGES C)

# ...
```

Project source directory example:

```sh
📂 SomeProjectName
└─📂 src               # Project source code
  ├─📄 main.c
  └─📄 ...
└─📂 subdirectory      # Subdirectory with its own CMakeLists
  ├─📄 CMakeLists.txt
  ├─📄 src.c
  └─📄 ...
├─📄 CMakeLists.txt    # Project main CMakeLists file
└─📄 ...
```

### 3.1. Including other CMake files

To maintain modularity and organization, other CMake files can be included
within the project:

```cmake
# Include CMake file using relative path
include(path/to/file.cmake)

# Include a CMake module
include(SomeCMakeModule)

# Add a subdirectory with its own CMakeLists.txt
add_subdirectory(subdirectory)
```

This allows breaking down complex configurations into manageable components.

## 4. CMake syntax

### 4.1. Variables

In CMake, variables are essential for storing and manipulating data throughout
the project's configuration and build processes. They play a pivotal role in
customizing builds and managing project-specific settings. Variable names are
case-sensitive.

#### 4.1.1. Setting variables

Variables are set using the `set()` command, where a value is assigned to a
variable:

```cmake
# A local variable
set(foobar "value")

# Cache variables are stored and persist across the entire build system
set(FOOBAR "value" CACHE STRING "Documentation for this variable")
```

Cache variables, in particular, are noteworthy because they offer a means to
store values that remain consistent across different CMake runs and are
accessible to various parts of the project. These variables also require a
short documentation help text to describe their purpose.

#### 4.1.2. Working with cache variables

Cache variables are highly versatile and can be influenced from various sources,
such as the command line. This allows for dynamic configuration adjustments:

```sh
# Pass a value to a cache variable on the command line
cmake -DFOOBAR="value" -S source-directory -B build-directory
```

Cache variables become particularly useful for customizing builds, specifying
project-wide settings, and adapting configurations to different environments.

#### 4.1.3. Using variables

Variable references in CMake use `$` sigil symbol and are enclosed within curly
brackets `{}`.

```cmake
set(foobar "value")
message(STATUS "${foobar}")

# Output: value
```

Certain commands, such as `if()`, also support variable names:

```cmake
if(foobar STREQUAL "value")
  message(STATUS "Variable foobar=${foobar}")
endif()

# Output: Variable foobar=value
```

#### 4.1.4. Lists

Lists in CMake are strings separated with `;` that can be iterated over in
loops, such as `foreach`.

```cmake
# Create a list
set(listVariable a b c)

# Or
set(listVariable "a;b;c")

# This is a normal string, not a list
set(stringVariable "a b c")
```

The `list()` command performs operations on lists.

Lists are frequently used for tasks like specifying source files, compiler
flags, and dependencies.

### 4.2. Functions

CMake function is created with the `function()` command:

```cmake
# Define a function
function(print_message argument)
  message(STATUS "${argument}")
endfunction()

# Call the function
print_message("Hello, World")

# Output: Hello, World
```

### 4.3. Arguments

Arguments in CMake can be passed to commands in three ways.

#### 4.3.1. Quoted arguments

Here variable is set to a literal string `quoted argument`:

```cmake
set(foobar "quoted argument")
```

#### 4.3.2. Unquoted arguments

Here variable is set to a literal string `unquoted`:

```cmake
set(foobar unquoted)
```

#### 4.3.3. Bracket arguments

Bracket arguments are wrapped in pairs of double brackets `[[..]]` and any
number of `=` characters in between (`[[`, `]]`, `[=[`, `]=]`, `[==[`, `]==]`,
etc.) and passed as-is. No escaping of special characters is needed, but also
variables are not expanded. They are most commonly used for passing strings of
code or regular expressions.

For example

```cmake
message(STATUS [=[
Inside bracket arguments the \-escape sequences and ${variable} references are
not evaluated. Argument can also contain ; and other special ]] characters.
]=])
```

will output:

```
Inside bracket arguments the \-escape sequences and ${variable} references are
not evaluated. Argument can also contain ; and other special ]] characters.
```

## 5. Targets

CMake revolves around targets, which represent various components of the
project. There are primarily two types: libraries and executables.

```cmake
# Create an executable target
add_executable(php php.c php_2.c ...)

# Create a library target
add_library(extension extension.c src.c ...)
```

Library can also have a type specified. For example, a shared library:

```cmake
add_library(extension SHARED extension.c src.c)
```

> [!IMPORTANT]
> There are several library types:
>
> ```cmake
> add_library(<name> [OBJECT|MODULE|SHARED|STATIC] <sources>...)
> ```
>
> The keywords `OBJECT`, `MODULE`, `SHARED`, and `STATIC` specify how the
> library is built. `OBJECT` libraries will compile source files to binary
> object files without the linking step. These objects can be then referenced in
> other CMake targets. `SHARED` libraries can be linked dynamically or
> dynamically loaded at program runtime with `dlopen()` on *nix systems, or
> `LoadLibrary()` on Windows. `MODULE` library is a special CMake concept that
> prevents such targets to be linked dynamically with `target_link_libraries()`
> and are intended to be only dynamically loaded during runtime. `STATIC`
> library is an archive of built object files that can be linked to other
> targets.

The concepts of executable and library targets can be illustrated through
examples of using a compiler like `gcc`.

### 5.1. Executables

Executables are programs that are intended to be run.

```sh
# Build executable from source
gcc -o php php.c
# Executable can be then run by the user
./php
```

### 5.2. OBJECT library

When using OBJECT library, each source file will be compiled to a binary object
file. Behind the scene, CMake takes care of compile flags and adjusts the build
command. For example:

```sh
# Compile each file to a binary object
gcc -c -o extension.o extension.c
gcc -c -o src.o src.c
```

### 5.3. SHARED library

CMake automatically adds sensible linker flags when building `SHARED` library.
For example, `-shared`, `-Wl,-soname,extension.so`, position-independent code
flag `-fPIC`, and similar.

```sh
# Compile each source file to a binary object file with the -fPIC
gcc -fPIC -c -o extension.o extension.c
gcc -fPIC -c -o src.o src.c
# Generate shared object from object files
gcc -fPIC -shared -Wl,-soname,extension.so -o extension.so extension.o src.o
```

### 5.4. MODULE library

The `MODULE` library, on the other hand, is similar to the `SHARED`. However,
CMake uses slightly different flags and treats it differently in CMake code. A
`MODULE` library cannot be linked with `target_link_libraries()` in CMake, and
certain handling inside CMake differs.

```sh
# Compile each source file to a binary object file with the -fPIC
gcc -fPIC -c -o extension.o extension.c
gcc -fPIC -c -o src.o src.c
# Generate shared object from object files
gcc -fPIC -shared -o extension.so extension.o src.o
```

Both `MODULE` and `SHARED` libraries can be loaded with `dlopen`-alike
functionality during program runtime. For example:

```c
/* main.c */
#include <dlfcn.h>

int main(void)
{
    void *handle = dlopen("extension.so", RTLD_LAZY);
    void (*extension_function_ptr)() = dlsym(handle, "extension_function");
    extension_function_ptr();
    dlclose(handle);

    return 0;
}
```

### 5.5. STATIC library

`STATIC` libraries are intended to be linked statically to other libraries or
executables where they become part of the final binary.

```sh
# Compile source file to a binary object file
gcc -c -o main.o main.c
# Bundle object file(s) into a static library
ar rcs libmain.a main.o
# Link static library to an output program
gcc -o program program.c -L. -lmain
```

### 5.6. Working with targets

Once targets are defined, they can be fine-tuned with additional configurations:

```cmake
# Add more source files to a target
target_sources(php INTERFACE|PUBLIC|PRIVATE src_3.c)

# Specify include directories for a target
target_include_directories(php INTERFACE|PUBLIC|PRIVATE include/1 include/2)

# Set compile options for a target
target_compile_options(php INTERFACE|PUBLIC|PRIVATE -Wno-implicit-fallthrough)

# Link libraries, flags, or another targets to a target
target_link_libraries(php INTERFACE|PUBLIC|PRIVATE main)
```

The keywords `INTERFACE`, `PUBLIC`, and `PRIVATE` exhibit similarities to the
visibility concept in object-oriented programming. When using `PRIVATE`, it
signifies that an item is exclusively accessible to the defined target and is
not exposed to any depending targets. On the other hand, `PUBLIC` indicates that
the item is accessible both to the defined target and any depending targets.
Lastly, `INTERFACE` denotes that the item is solely accessible to depending
targets and is not accessible to the defining target itself.

## 6. Verification and checks in CMake

In CMake, various verification and validation tasks can be performed to ensure
the availability of headers, symbols, struct members, as well as assess the
compilation and execution of C code. These checks are crucial for configuring
the project correctly.

CMake provides a range of commands, many of which are found in separate CMake
modules bundled with CMake. These modules need to be included before utilizing
the respective verification commands:

### 6.1. Header availability check

To verify if a header file is available:

```cmake
include(CheckIncludeFiles)
check_include_files(sys/types.h HAVE_SYS_TYPES_H)
```

### 6.2. C source compilation check

To determine if a C source file compiles and links into an executable:

```cmake
include(CheckSourceCompiles)
check_source_compiles(C "int main(void) { return 0; }" HAVE_WORKING_HELLO_WORLD)
```

This command initiates a compilation and linking step, as illustrated here:

```sh
gcc -o out check_program.c
```

### 6.3. C source compilation and execution check

For a more comprehensive assessment that includes compiling, linking, and
executing the C code:

```cmake
include(CheckSourceRuns)
check_source_runs(C "int main(void) { return 0; }" HAVE_WORKING_HELLO_WORLD)
```

This will compile, link and also run the program to check if the return code is
0:

```sh
gcc -o out check_program.c
./out
```

## 7. Generating a configuration header

Once the necessary checks have been completed during the configuration phase,
a configuration header file can be created. This header file serves as a
configuration component in customizing the project's build based on the check
results, and it is generated using the `configure_file()` command.

```cmake
# Generating a header file from the config.h.in template
configure_file(
  src/config.h.in
  src/config.h
)
```

The `configure_file()` command reads a template file `src/config.h.in`, which
contains placeholders for variables and their associated values:

```c
/* src/config.h.in */

/* Define to 1 if system has the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H @HAVE_SYS_TYPES_H@
```

and replaces the placeholders in the template file with the actual values of the
corresponding variables. For example:

```c
/* src/config.h */

/* Define to 1 if system has the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1
```

This resulting `src/config.h` header file is used for directing the build system
and source code, as it defines preprocessor macros based on the configuration
results. It enables conditional compilation and helps ensure that the project
behaves correctly across various environments.

```c
/* src/main.c */

#include "config.h"

#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

int main(void)
{
    return 0;
}
```

## 8. Where to go from here?

This section has provided a general overview of the most crucial features of
CMake. To explore deeper into mastering CMake, it is highly recommended to start
with the
[step-by-step tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html).

Furthermore, the [CMake documentation](https://cmake.org/documentation/) offers
comprehensive guidance on CMake's features and functionalities.
