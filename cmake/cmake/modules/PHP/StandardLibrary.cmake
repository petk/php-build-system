#[=============================================================================[
# PHP/StandardLibrary

This module determines the C standard library used for the build:

```cmake
include(PHP/StandardLibrary)
```

## Cache variables

* `PHP_C_STANDARD_LIBRARY`

  Lowercase name of the C standard library:

    * `cosmopolitan`
    * `dietlibc`
    * `glibc`
    * `llvm`
    * `mscrt`
    * `musl`
    * `uclibc`

  If library cannot be determined, it is set to empty string.

* `__MUSL__` - Whether the C standard library is musl.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/StandardLibrary)
```
#]=============================================================================]

include_guard(GLOBAL)

if(DEFINED PHP_C_STANDARD_LIBRARY)
  return()
endif()

include(CheckSymbolExists)
include(CMakePushCheckState)

set(PHP_C_STANDARD_LIBRARY "" CACHE INTERNAL "The C standard library.")

message(CHECK_START "Checking C standard library")

# The MS C runtime library (CRT).
if(MSVC)
  set(_PHP_C_STANDARD_LIBRARY_MSCRT TRUE)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(_MSC_VER stdio.h _PHP_C_STANDARD_LIBRARY_MSCRT)
  cmake_pop_check_state()
endif()
if(_PHP_C_STANDARD_LIBRARY_MSCRT)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "mscrt")
  message(CHECK_PASS "MS C runtime library (CRT)")
  return()
endif()

# The uClibc and its maintained fork uClibc-ng behave like minimalistic GNU C
# library but have differences. They can be determined by the __UCLIBC__ symbol
# and must be checked first because they also define the __GLIBC__ symbol.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__UCLIBC__ features.h _PHP_C_STANDARD_LIBRARY_UCLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_UCLIBC)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "uclibc")
  message(CHECK_PASS "uClibc")
  return()
endif()

# The diet libc.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__dietlibc__ features.h _PHP_C_STANDARD_LIBRARY_DIETLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_DIETLIBC)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "dietlibc")
  message(CHECK_PASS "diet libc")
  return()
endif()

# The Cosmopolitan Libc.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__COSMOPOLITAN__ "" _PHP_C_STANDARD_LIBRARY_COSMOPOLITAN)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_COSMOPOLITAN)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "cosmopolitan")
  message(CHECK_PASS "Cosmopolitan Libc")
  return()
endif()

# The GNU C standard library has __GLIBC__ and __GLIBC_MINOR__ symbols since the
# very early version 2.0.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__GLIBC__ features.h _PHP_C_STANDARD_LIBRARY_GLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_GLIBC)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "glibc")
  message(CHECK_PASS "GNU C (glibc)")
  return()
endif()

# The LLVM libc.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__LLVM_LIBC__ features.h _PHP_C_STANDARD_LIBRARY_LLVM)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_LLVM)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "llvm")
  message(CHECK_PASS "LLVM libc")
  return()
endif()

# The musl libc doesn't advertise itself with symbols, so it must be determined
# heuristically.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__DEFINED_va_list stdarg.h _PHP_C_STANDARD_LIBRARY_MUSL)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_MUSL)
  set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "musl")
else()
  # Otherwise, try determining musl libc with ldd.
  block()
    execute_process(
      COMMAND ldd --version
      OUTPUT_VARIABLE version
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(version MATCHES ".*musl libc.*")
      set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "musl")
    endif()
  endblock()
endif()
if(PHP_C_STANDARD_LIBRARY STREQUAL "musl")
  set(__MUSL__ TRUE CACHE INTERNAL "Whether the C standard library is musl.")
  message(CHECK_PASS "musl")
  return()
endif()

# Instead of an "unknown", output a common "libc" result.
message(CHECK_FAIL "libc")
