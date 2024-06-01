# Cross-compiling

## Index

* [1. Cross-compilation considerations](#1-cross-compilation-considerations)
* [2. Cross-compilation with CMake](#2-cross-compilation-with-cmake)
  * [2.1. Setting known cache variables manually](#21-setting-known-cache-variables-manually)
  * [2.2. CMAKE\_CROSSCOMPILING](#22-cmake_crosscompiling)
  * [2.3. CMAKE\_CROSSCOMPILING\_EMULATOR](#23-cmake_crosscompiling_emulator)
  * [2.4. Toolchain files](#24-toolchain-files)
* [3. Cross-compilation with Autotools](#3-cross-compilation-with-autotools)
  * [3.1. Cache variables](#31-cache-variables)

## 1. Cross-compilation considerations

Cross-compilation is a method where a project is compiled on one system but
targeted to run on another. In cross-compilation scenarios, running C test
programs with build system run checks isn't always feasible or guaranteed.

## 2. Cross-compilation with CMake

CMake has `try_run()`, `check_source_runs()`, and
`check_<LANG>_source_runs()` to check whether a test program compiles and runs
as expected.

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

### 2.1. Setting known cache variables manually

When the target system is known how certain check is working, the cache
variables can be set manually. For example:

```sh
cmake . -DCMAKE_SYSTEM_NAME=Linux -DHAVE_WORKING_HELLO_WORLD_EXITCODE=0
```

### 2.2. CMAKE_CROSSCOMPILING

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

### 2.3. CMAKE_CROSSCOMPILING_EMULATOR

By setting the `CMAKE_CROSSCOMPILING_EMULATOR` variable, test programs can be
then run with provided emulator if possible on the host system and for the
targeted platform.

```sh
cmake . -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_CROSSCOMPILING_EMULATOR=/usr/bin/env
```

### 2.4. Toolchain files

Cross-compilation uses so-called toolchain files, where all the unknown
variables are manually defined for the targeted platform.

```sh
cmake --toolchain customToolchain.cmake -S ../php-src -B build-directory
```

## 3. Cross-compilation with Autotools

Autotools has `AC_RUN_IFELSE` macro to check whether a test program compiles and
runs as expected. To cross-compile PHP when using native Autotools-based build
system can be done by setting the `host` manually:

```sh
# Generate configure script
./buildconf

# Configure PHP build
./configure --host=<target-triplet>

# Compile PHP sources
make
```

The target triplet is in format of `cpu-vendor-os`. For example,
`x86_64-w64-mingw64`.

> [!NOTE]
> In Autoconf the convention is to use the `--host` option to define the target
> system. There is also a `--target` option, which sets the type of system for
> which any compiler tools in the package produce code. It is rarely needed if
> not at all. By default, it is the same as host.

In cross-compilation mode the `cross_compiling` variable is set to `yes`:

```m4
AS_VAR_IF([cross_compiling], [yes],
  [AC_MSG_NOTICE([Cross-compiling: Certain checks may not be applicable.])])
```

### 3.1. Cache variables

Ideally, running test programs with `AC_RUN_IFELSE` should be avoided in favor
of compile or link checks. However certain checks require runtime (to run the
executable binary test programs), which might not be possible in cross-compiling
mode. In these cases the Autoconf cache variables can be used to manually
determine the platform characteristics. For example:

```sh
./configure --host=<target-triplet> \
  ac_cv_func_getaddrinfo=yes \
  ac_cv_copy_file_range=yes \
  ac_cv_syscall_shadow_stack_exists=yes \
  php_cv_ubsan_no_function=yes \
  ac_cv_time_r_type=yes \
  ac_cv_ebcdic=no \
  ac_cv_have_broken_gcc_strlen_opt=no \
  php_cv_type_cookie_off64_t=yes \
  ac_cv_c_bigendian_php=no \
  ac_cv_write_stdout=yes \
  php_cv_iconv_ignore=yes \
  php_cv_shm_mmap_posix=yes \
  php_cv_func_sched_getcpu=yes \
  ac_cv_have_pcre2_jit=yes \
  php_cv_func_ttyname_r=yes \
  ac_cv_flush_io=yes \
  ac_cv_crypt_des=yes \
  ac_cv_crypt_ext_des=yes \
  ac_cv_crypt_md5=yes \
  ac_cv_crypt_blowfish=yes \
  ac_cv_crypt_sha512=yes \
  ac_cv_crypt_sha256=yes
```
