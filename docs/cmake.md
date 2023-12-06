# Quick introduction to CMake

This is a simple introduction to CMake in general, aimed at providing a basic
understanding of its fundamentals.

* [1. Command-line usage](#1-command-line-usage)
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
* [4. Functions](#4-functions)
* [5. Verification and checks in CMake](#5-verification-and-checks-in-cmake)
  * [5.1. Header availability check](#51-header-availability-check)
  * [5.2. C source compilation check](#52-c-source-compilation-check)
  * [5.3. C source compilation and execution check](#53-c-source-compilation-and-execution-check)
  * [5.4. Cross-compilation considerations](#54-cross-compilation-considerations)
* [6. Generating a configuration header](#6-generating-a-configuration-header)
* [7. Where to go from here?](#7-where-to-go-from-here)
* [8. Advanced topics](#8-advanced-topics)
  * [8.1. Targets](#81-targets)
    * [8.1.1. OBJECT library](#811-object-library)
    * [8.1.2. SHARED library](#812-shared-library)
    * [8.1.3. MODULE library](#813-module-library)
    * [8.1.4. STATIC library](#814-static-library)
    * [8.1.5. Executable target](#815-executable-target)

## 1. Command-line usage

When working with CMake, there are two primary phases: the configuration and
generation phase, followed by the build phase.

### 1.1. Configuration and generation phase

In this phase, CMake performs essential tasks to set up a build environment:

```sh
# Generate build system from a source directory to a build directory:
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

```cmake
# CMakeLists.txt

# Require a minimum CMake version to build the project
cmake_minimum_required(VERSION 3.25)

# Set the project name and its metadata
project(<ProjectName> VERSION 1.0.0 LANGUAGES C)

# ...
```

### 2.1. Including other CMake files

To maintain modularity and organization, you can include other CMake files
within your project:

```cmake
# Include CMake file using relative path
include(path/to/file.cmake)

# Include a CMake module
include(CheckCSourceCompiles)
```

This allows you to break down complex configurations into manageable components.

### 2.2. Defining targets

CMake revolves around targets, which represent various components of your
project. There are primarily two types: libraries and executables.

```cmake
# Create a library target
add_library(extension OBJECT|MODULE|SHARED|STATIC extension.c src.c ...)

# Create an executable target
add_executable(php php.c php_2.c ...)
```

The keywords `OBJECT`, `MODULE`, `SHARED`, and `STATIC` specify how the library
is built. `OBJECT` libraries will compile source files to binary object files
without the linking step. These objects can be then referenced in other CMake
targets. `SHARED` libraries can be linked dynamically and loaded at program
runtime or dynamically loaded with `dlopen()` on *nix systems or `LoadLibrary()`
on Windows. `MODULE` library is a special CMake concept that prevents targets to
be linked dynamically with `target_link_libraries()` and are intended
specifically to be dynamically loaded at program runtime. `STATIC` library, on
the other hand, is an archive of built object files that can be linked to other
targets.

### 2.3. Working with targets

Once you've defined your targets, you can fine-tune them with additional
configurations:

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

Lists in CMake are strings separated with `;` that can be iterated over in
loops, such as `foreach`.

```cmake
# Create a list
set(list_variable a b c)

# Or
set(list_variable "a;b;c")

# This is a normal string, not a list
set(string_variable "a b c")
```

The `list()` command performs operations on lists.

Lists are frequently used for tasks like specifying source files, compiler
flags, and dependencies.

## 4. Functions

CMake function is created with the `function()` command:

```cmake
# Define a function
function(print_message argument)
  message("${argument}")
endfunction()

# Call the function
print_message("Hello, World")
# Outputs: Hello, World
```

## 5. Verification and checks in CMake

In CMake, you can perform various verification and validation tasks to ensure
the availability of headers, symbols, struct members, as well as assess the
compilation and execution of C code. These checks are crucial for configuring
your project correctly.

CMake provides a range of commands, many of which are found in separate CMake
modules bundled with CMake. These modules need to be included before utilizing
the respective verification commands:

### 5.1. Header availability check

To verify if a header file is available:

```cmake
include(CheckIncludeFile)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
```

### 5.2. C source compilation check

To determine if a C source file compiles and links into an executable:

```cmake
include(CheckCSourceCompiles)
check_c_source_compiles("int main(void) { return 0; }" HAVE_WORKING_HELLO_WORLD)
```

This command initiates a compilation and linking step, as illustrated here:

```sh
gcc -o out check_program.c
```

### 5.3. C source compilation and execution check

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

### 5.4. Cross-compilation considerations

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

## 6. Generating a configuration header

Once the necessary checks have been completed during the configuration phase,
you can proceed to create a configuration header file. This header file serves
as a configuration component in customizing your project's build based on the
check results, and it is generated using the `configure_file()` command.

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

## 7. Where to go from here?

This section has provided a general overview of the most crucial features of
CMake. To explore deeper into mastering CMake, it is highly recommended to start
with the
[step-by-step tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html).

Furthermore, the [CMake documentation](https://cmake.org/documentation/) offers
comprehensive guidance on CMake's features and functionalities.

The upcoming sections of this document cover advanced topics, providing an
additional layer of understanding of CMake. While the following topics are less
critical for a successful start with CMake, you can safely revisit them at a
later time.

## 8. Advanced topics

This section offers supplementary explanations and tricks that could not find
place elsewhere or are not sufficiently covered in the CMake documentation.
These insights and tips can be valuable when deep-diving into CMake.

### 8.1. Targets

```cmake
add_library(extension OBJECT|MODULE|SHARED|STATIC extension.c src.c ...)
add_executable(php php.c php_2.c ...)
```

The concepts of library and executable targets are best illustrated through
examples using `gcc`:

#### 8.1.1. OBJECT library

OBJECT library will compile each source file to a binary object file:

```sh
gcc -c -o extension.o extension.c
gcc -c -o src.o src.c
```

#### 8.1.2. SHARED library

CMake automatically adds sensible linker flags when building SHARED library. For
example, `-shared`, `-Wl,-soname,extension.so`, position-independent code flag
`-fPIC`, and similar.

```sh
# Compile each source file to a binary object file with the -fPIC
gcc -fPIC -c -o extension.o extension.c
gcc -fPIC -c -o src.o src.c
# Generate shared object from object files
gcc -fPIC -shared -Wl,-soname,extension.so -o extension.so extension.o src.o
```

#### 8.1.3. MODULE library

`MODULE` library is on the other hand the same as `SHARED` except CMake will use
different link flags. MODULE library cannot be linked with
`target_link_libraries()` in CMake and certain handling inside CMake is
different.

```sh
# Compile each source file to a binary object file with the -fPIC flag
gcc -fPIC -c -o extension.o extension.c
gcc -fPIC -c -o src.o src.c
# Generate shared object from object files
gcc -fPIC -shared -o extension.so extension.o src.o
```

Both `MODULE` and `SHARED` libraries can be loaded with `dlopen` in C:

```c
/* extension.c */
#include <stdio.h>

void extension_function() {
  printf("extension_function called\n");
}
```

```c
/* main.c */
#include <dlfcn.h>
#include <stdio.h>

int main(void) {
    void *handle = dlopen("extension.so", RTLD_LAZY);
    if (!handle) {
        printf("Error opening module: %s\n", dlerror());
        return 1;
    }

    void (*extension_function_ptr)() = dlsym(handle, "extension_function");
    if (!extension_function_ptr) {
        printf("Error finding symbol: %s\n", dlerror());
        dlclose(handle);
        return 1;
    }

    extension_function_ptr();

    dlclose(handle);
    return 0;
}
```

#### 8.1.4. STATIC library

STATIC libraries are intended to be linked statically to other libraries or
executables and then become part of the final binary.

```sh
# Create object file without the position-independent code flag -fPIC
gcc -c -o main.o main.c
# Bundle object file(s) into a static library
ar rcs main.a main.o
```

#### 8.1.5. Executable target

```sh
gcc -o php php.c
```
