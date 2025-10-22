# Cross-compiling

## Index

* [1. Cross-compilation considerations](#1-cross-compilation-considerations)
* [2. Cross-compilation with CMake](#2-cross-compilation-with-cmake)
  * [2.1. Setting known cache variables manually](#21-setting-known-cache-variables-manually)
  * [2.2. CMAKE\_CROSSCOMPILING variable](#22-cmake_crosscompiling-variable)
  * [2.3. CMAKE\_CROSSCOMPILING\_EMULATOR variable](#23-cmake_crosscompiling_emulator-variable)
  * [2.4. Toolchain files](#24-toolchain-files)
* [3. Cross-compilation with Autotools](#3-cross-compilation-with-autotools)
  * [3.1. PHP cache variables](#31-php-cache-variables)

## 1. Cross-compilation considerations

Cross-compilation is a method where a project is compiled on one system and
targeted to run on another. In cross-compilation scenarios, running C test
programs with build system run checks isn't always feasible or guaranteed.

## 2. Cross-compilation with CMake

CMake has `try_run()`, `check_source_runs()`, and
`check_<LANG>_source_runs()` commands to check whether a test program compiles
and runs as expected.

A minimum simplistic example:

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 4.2...4.3)

project(PHP C)

include(CheckSourceRuns)

# Compile and run a test program.
check_source_runs(C [[
  #include <stdio.h>
  int main(void)
  {
    printf("Hello world");
    return 0;
  }
]] PHP_HAVE_HELLO_WORLD)
```

Setting target system name puts CMake in the cross-compilation mode:

```sh
cmake -DCMAKE_SYSTEM_NAME=Linux -S . -B build
```

CMake will emit error indicating that cache variable
`PHP_HAVE_HELLO_WORLD_EXITCODE` should be set manually:

```txt
-- Performing Test PHP_HAVE_HELLO_WORLD
CMake Error: try_run() invoked in cross-compiling mode, please set the following
cache variables appropriately:
   PHP_HAVE_HELLO_WORLD_EXITCODE (advanced)
For details see .../TryRunResults.cmake
-- Performing Test PHP_HAVE_HELLO_WORLD - Failed
-- Configuring incomplete, errors occurred!
```

Here are some options to consider, when encountering cross-compilation in CMake.

### 2.1. Setting known cache variables manually

When certain check result is known for the target system, the cache variables
can be set manually. For example:

```sh
cmake -DCMAKE_SYSTEM_NAME=Linux -DPHP_HAVE_HELLO_WORLD_EXITCODE=0 -S . -B build
```

### 2.2. CMAKE_CROSSCOMPILING variable

When CMake is in cross-compilation mode, the `CMAKE_CROSSCOMPILING` variable is
automatically set. It can be used to run certain checks conditionally.

```cmake
if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: Certain checks may not be applicable.")
else()
  check_source_runs(C [[
    #include <stdio.h>
    int main(void)
    {
      printf("Hello world");
      return 0;
    }
  ]] PHP_HAVE_HELLO_WORLD)
endif()
```

### 2.3. CMAKE_CROSSCOMPILING_EMULATOR variable

By setting the `CMAKE_CROSSCOMPILING_EMULATOR` variable, test programs can be
then run with provided emulator as they were running on the targeted system if
such emulator exists on the host system.

```sh
cmake -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_CROSSCOMPILING_EMULATOR=/usr/bin/env -S . -B build
```

Example, how to use the cross-compiling emulator with the run check:

```cmake
if(CMAKE_CROSSCOMPILING_EMULATOR OR NOT CMAKE_CROSSCOMPILING)
  check_source_runs(C [[
    #include <stdio.h>
    int main(void)
    {
      printf("Hello world");
      return 0;
    }
  ]] PHP_HAVE_HELLO_WORLD)
else()
  message(STATUS "Cross-compiling: Certain checks may not be applicable.")
endif()
```

### 2.4. Toolchain files

Cross-compilation uses so-called toolchain files, where all the unknown
variables are manually defined for the targeted platform.

```sh
cmake --toolchain customToolchain.cmake -S ../php-src -B build-directory
# Also a CMAKE_TOOLCHAIN_FILE variable can be used:
cmake -DCMAKE_TOOLCHAIN_FILE=someToolchain.cmake -S ../php-src -B build-directory
```

## 3. Cross-compilation with Autotools

To cross-compile PHP when using native Autotools-based build system, the `host`
and `build` options need to be set:

```sh
# Generate configure script
./buildconf

# Configure PHP build
./configure --build=<build-triplet> --host=<target-triplet>

# Compile PHP sources
make
```

The `--build` sets the system on which PHP is being built, and the `--host`
option sets the system for which the PHP is targeted to run on.

The triplet is in format of `cpu-vendor-os`. For example, the build triplet
`x86_64-pc-linux-gnu` and target triplet `x86_64-w64-mingw64` will mean to build
PHP on 64-bit Linux with x86_64 processor to run on Windows 64-bit system with
x86_64 processor:

```sh
./configure --build=x86_64-pc-linux-gnu --host=x86_64-w64-mingw64
```

> [!NOTE]
> Autoconf convention is to use the `--host` option to define the target system.
> There is also a `--target` option, which sets the type of system for which any
> compiler tools in the package produce code. It is rarely needed. By default,
> it is the same as host.

In cross-compilation mode the `cross_compiling` variable is set to `yes`:

```m4
AS_VAR_IF([cross_compiling], [yes],
  [AC_MSG_NOTICE([Cross-compiling: Certain checks may not be applicable.])])
```

Autotools has `AC_RUN_IFELSE` macro to check whether a test program compiles and
runs as expected.

```m4
AC_MSG_CHECKING([for working hello world])
AC_RUN_IFELSE([AC_LANG_SOURCE([
    #include <stdio.h>
    int main(void)
    {
      printf("Hello world");
      return 0;
    }
  ])],
  [AC_MSG_RESULT([yes])
    AC_DEFINE([PHP_HAVE_HELLO_WORLD], [1], [Define if hello world works.])],
  [AC_MSG_RESULT([no])],
  [AC_MSG_RESULT([no (cross-compiling)])])
```

The 3 action arguments at the end of `AC_RUN_IFELSE`:

* action if test program ran successfully
* action if test program didn't run successfully
* action when cross-compiling

By adjusting the run check with cache variables, users can override the
cross-compilation result. For example:

```m4
AC_CACHE_CHECK([for working hello world], [php_cv_have_hello_world],
  [AC_RUN_IFELSE([AC_LANG_SOURCE([
      #include <stdio.h>
      int main(void)
      {
        printf("Hello world");
        return 0;
      }
    ])],
  [php_cv_have_hello_world=yes],
  [php_cv_have_hello_world=no],
  [php_cv_have_hello_world=no])])

AS_VAR_IF([php_cv_have_hello_world], [yes],
  [AC_DEFINE([PHP_HAVE_HELLO_WORLD], [1], [Define if hello world works.])])
```

Cache variables can be then passed to configure script to override the check:

```sh
./configure \
  --build=<build-triplet> \
  --host=<target-triplet> \
  php_cv_have_hello_world=yes
```

Ideally, running test programs with `AC_RUN_IFELSE` should be avoided in favor
of compile or link checks. However, certain checks require runtime (to run the
executable binary test programs), which might not be possible in cross-compiling
mode.

### 3.1. PHP cache variables

Autoconf cache variables can be used to manually determine the platform
characteristics. PHP cache variables to consider adjusting when cross-compiling:

```sh
./configure --host=<target-triplet> --build=<build-triplet> \
  php_cv_func_getaddrinfo=yes \
  php_cv_have_shadow_stack_syscall=yes \
  php_cv_ubsan_no_function=yes \
  php_cv_type_cookie_off64_t=yes \
  php_cv_have_write_stdout=yes \
  ac_cv_c_bigendian_php=no \
  php_cv_iconv_ignore=yes \
  php_cv_shm_ipc=yes \
  php_cv_shm_mmap_anon=yes \
  php_cv_shm_mmap_posix=yes \
  php_cv_func_sched_getcpu=yes \
  php_cv_have_pcre2_jit=yes \
  php_cv_have_flush_io=yes \
  ac_cv_crypt_des=yes \
  ac_cv_crypt_ext_des=yes \
  ac_cv_crypt_md5=yes \
  ac_cv_crypt_blowfish=yes \
  ac_cv_crypt_sha512=yes \
  ac_cv_crypt_sha256=yes \
  php_cv_func_clock_get_time=yes \
  php_cv_have_stack_limit=yes \
  php_cv_have_common_page_size=yes \
  php_cv_have_max_page_size=yes \
  php_cv_lib_curl_ssl=no \
  php_cv_lib_gd_gdImageCreateFrom*=yes \
  php_cv_sizeof_*=... \
  php_cv_func_ptrace=yes \
  php_cv_func_mach_vm_read=yes \
  php_cv_file_proc_mem=as|mem \
  php_cv_align_mm="(size_t)8 (size_t)3 0" \
  php_cv_func_pwrite=yes \
  php_cv_func_pread=yes
```

> [!WARNING]
> Cache variable names might change across the PHP versions.
