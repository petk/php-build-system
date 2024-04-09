# Cross-compiling

## Index

* [1. Cross-compilation considerations](#1-cross-compilation-considerations)
  * [1.1. Setting known cache variables manually](#11-setting-known-cache-variables-manually)
  * [1.2. CMAKE\_CROSSCOMPILING](#12-cmake_crosscompiling)
  * [1.3 CMAKE\_CROSSCOMPILING\_EMULATOR](#13-cmake_crosscompiling_emulator)
* [2. Toolchain files](#2-toolchain-files)

## 1. Cross-compilation considerations

Cross-compilation is a method where a project is compiled on one system but
targeted to run on another. In cross-compilation scenarios, running C test
programs using `try_run()`, `check_source_runs()`, or
`check_<LANG>_source_runs()` isn't always feasible or guaranteed.

A minimum simplistic example of cross-compilation:

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.25)

project(PHP LANGUAGES C)

include(CheckSourceRuns)

# Compile and run a test program.
check_source_runs(C [[
  #include <stdio.h>
  int main(void) {
    printf("Hello world");
    return 0;
  }
]] HAVE_WORKING_HELLO_WORLD)
```

```sh
# Setting target system name puts CMake in the cross-compilation mode.
cmake . -DCMAKE_SYSTEM_NAME=Linux
```

CMake will emit error indicating that cache variable
`HAVE_WORKING_HELLO_WORLD_EXITCODE` should be set manually:

```txt
-- Performing Test HAVE_WORKING_HELLO_WORLD
CMake Error: try_run() invoked in cross-compiling mode, please set the following
cache variables appropriately:
   HAVE_WORKING_HELLO_WORLD_EXITCODE (advanced)
For details see .../TryRunResults.cmake
-- Performing Test HAVE_WORKING_HELLO_WORLD - Failed
-- Configuring incomplete, errors occurred!
```

Here are some options to consider, when encountering cross-compilation.

### 1.1. Setting known cache variables manually

When the target system is known how certain check is working, the cache
variables can be set manually. For example:

```sh
cmake . -DCMAKE_SYSTEM_NAME=Linux -DHAVE_WORKING_HELLO_WORLD_EXITCODE=0
```

### 1.2. CMAKE_CROSSCOMPILING

When CMake is in cross-compilation mode, the `CMAKE_CROSSCOMPILING` variable is
set. It can be used to run certain checks conditionally.

```cmake
if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: Certain checks may not be applicable.")
else()
  check_source_runs(C [[
    #include <stdio.h>
    int main(void) {
      printf("Hello world");
      return 0;
    }
  ]] HAVE_WORKING_HELLO_WORLD)
endif()
```

### 1.3 CMAKE_CROSSCOMPILING_EMULATOR

By setting the `CMAKE_CROSSCOMPILING_EMULATOR` variable, test programs can be
then run with provided emulator if possible on the host system and for the
targeted platform.

```sh
cmake . -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_CROSSCOMPILING_EMULATOR=/usr/bin/env
```

## 2. Toolchain files

Cross-compilation uses so called toolchain files, where all the unknown
variables are manually defined for the targeted platform.

```sh
cmake --toolchain customToolchain.cmake -S ../php-src -B build-directory
```
