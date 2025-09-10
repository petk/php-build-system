#[=============================================================================[
# PHP/StandardLibrary

This module determines the C standard library used for the build.

Load this module in a CMake project with:

```cmake
include(PHP/StandardLibrary)
```

## Variables

Including this module will define the following variables:

### Cache variables

* `PHP_C_STANDARD_LIBRARY`

  Lowercase name of the C standard library. This internal cache variable will be
  set to one of the following values:

    * `cosmopolitan`
    * `dietlibc`
    * `glibc`
    * `llvm`
    * `mscrt`
    * `musl`
    * `uclibc`
    * "" (empty string)

      If C standard library cannot be determined, it is set to empty string.

### Result variables:

* `PHP_C_STANDARD_LIBRARY_CODE`

  CMake variable containing some helper code for use in the C configuration
  header.

  For example, when C standard library implementation is musl, the value of this
  variable will contain:

  ```c
  /* Define to 1 when using musl libc. */
  #define __MUSL__ 1
  ```

## Examples

Basic usage:

```cmake
# CMakeLists.txt

include(PHP/StandardLibrary)

message(STATUS "PHP_C_STANDARD_LIBRARY=${PHP_C_STANDARD_LIBRARY}")

file(CONFIGURE OUTPUT config.h CONTENT [[
@PHP_C_STANDARD_LIBRARY_CODE@
]])
```
#]=============================================================================]

# Skip in consecutive configuration phases and set configuration header code for
# consecutive module inclusions, if needed.
if(COMMAND _php_standard_library_get_code)
  _php_standard_library_get_code(PHP_C_STANDARD_LIBRARY_CODE)
  return()
endif()

include_guard(GLOBAL)

include(CheckSymbolExists)
include(CMakePushCheckState)

function(_php_standard_library_get_code result)
  string(
    CONCAT
    ${result}
    "/* Define to 1 when using musl libc. */\n"
    "#cmakedefine __MUSL__ 1\n"
  )

  if(PHP_C_STANDARD_LIBRARY STREQUAL "musl")
    set(__MUSL__ TRUE)
  else()
    set(__MUSL__ FALSE)
  endif()

  string(CONFIGURE "${${result}}" ${result} @ONLY)

  return(PROPAGATE ${result})
endfunction()

function(_php_standard_library_check)
  unset(PHP_C_STANDARD_LIBRARY)
  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The MS C runtime library (CRT).
  if(MSVC)
    set(PHP_C_STANDARD_LIBRARY "mscrt")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    check_symbol_exists(_MSC_VER stdio.h PHP_C_STANDARD_LIBRARY)
  endif()
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "mscrt")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The uClibc and its maintained fork uClibc-ng behave like minimalistic GNU C
  # library but have differences. They can be determined by the __UCLIBC__
  # symbol and must be checked first because they also define the __GLIBC__
  # symbol.
  check_symbol_exists(__UCLIBC__ features.h PHP_C_STANDARD_LIBRARY)
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "uclibc")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The diet libc.
  check_symbol_exists(__dietlibc__ features.h PHP_C_STANDARD_LIBRARY)
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "dietlibc")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The Cosmopolitan Libc.
  check_symbol_exists(__COSMOPOLITAN__ "" PHP_C_STANDARD_LIBRARY)
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "cosmopolitan")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The GNU C standard library has __GLIBC__ and __GLIBC_MINOR__ symbols since
  # the very early version 2.0.
  check_symbol_exists(__GLIBC__ features.h PHP_C_STANDARD_LIBRARY)
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "glibc")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The LLVM libc.
  check_symbol_exists(__LLVM_LIBC__ features.h PHP_C_STANDARD_LIBRARY)
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "llvm")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # The musl libc doesn't advertise itself with symbols, so it must be
  # determined heuristically.
  check_symbol_exists(__DEFINED_va_list stdarg.h PHP_C_STANDARD_LIBRARY)
  if(PHP_C_STANDARD_LIBRARY)
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "musl")
    return()
  endif()

  unset(PHP_C_STANDARD_LIBRARY CACHE)

  # Otherwise, try determining musl libc with ldd.
  execute_process(
    COMMAND ldd --version
    OUTPUT_VARIABLE version
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(version MATCHES ".*musl libc.*")
    set_property(CACHE PHP_C_STANDARD_LIBRARY PROPERTY VALUE "musl")
    return()
  endif()

  set(PHP_C_STANDARD_LIBRARY "" CACHE INTERNAL "")
endfunction()

function(_php_standard_library)
  # Skip in consecutive runs.
  if(DEFINED PHP_C_STANDARD_LIBRARY)
    return()
  endif()

  message(CHECK_START "Checking C standard library")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    _php_standard_library_check()
  cmake_pop_check_state()

  if(PHP_C_STANDARD_LIBRARY STREQUAL "mscrt")
    message(CHECK_PASS "MS C runtime library (CRT)")
  elseif(PHP_C_STANDARD_LIBRARY STREQUAL "uclibc")
    message(CHECK_PASS "uClibc")
  elseif(PHP_C_STANDARD_LIBRARY STREQUAL "dietlibc")
    message(CHECK_PASS "diet libc")
  elseif(PHP_C_STANDARD_LIBRARY STREQUAL "cosmopolitan")
    message(CHECK_PASS "Cosmopolitan Libc")
  elseif(PHP_C_STANDARD_LIBRARY STREQUAL "glibc")
    message(CHECK_PASS "GNU C (glibc)")
  elseif(PHP_C_STANDARD_LIBRARY STREQUAL "llvm")
    message(CHECK_PASS "LLVM libc")
  elseif(PHP_C_STANDARD_LIBRARY STREQUAL "musl")
    message(CHECK_PASS "musl libc")
  else()
    # Instead of an "unknown", output a common "libc" result message.
    message(CHECK_FAIL "libc")
  endif()

  set_property(
    CACHE PHP_C_STANDARD_LIBRARY
    PROPERTY HELPSTRING "The C standard library."
  )
endfunction()

_php_standard_library()
_php_standard_library_get_code(PHP_C_STANDARD_LIBRARY_CODE)
