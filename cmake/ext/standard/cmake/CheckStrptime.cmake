#[=============================================================================[
# CheckStrptime

Check `strptime()` and its declaration.

Note: This module is obsolete. PHP `strptime()` is deprecated as of PHP 8.1.0.

## Cache variables

* `HAVE_STRPTIME`

  Whether `strptime()` is available.

## Result variables

* `HAVE_STRPTIME_DECL_FAILS`

  Whether `strptime()` declaration fails.

## Usage

```cmake
# CMakeLists.txt
include(cmake/CheckStrptime.cmake)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckFunctionExists)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)

if(PHP_VERSION VERSION_GREATER_EQUAL 9.0)
  message(
    DEPRECATION
    "PHP/CheckStrptime module is obsolete and should be removed. PHP "
    "'strptime()' function is deprecated as of PHP 8.1.0."
  )
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(strptime time.h HAVE_STRPTIME)
cmake_pop_check_state()

if(HAVE_STRPTIME)
  set(HAVE_STRPTIME_DECL_FAILS TRUE)
  return()
endif()

# The rest of this module is obsolete because strptime(), where available,
# simply needs the _GNU_SOURCE defined or compiler flag -std=gnuXX appended to
# be declared in time.h. This part can be removed in favor of the above
# check_symbol_exists().

# Check if linker sees the function.
if(NOT HAVE_STRPTIME)
  unset(HAVE_STRPTIME CACHE)
  check_function_exists(strptime HAVE_STRPTIME)
endif()

if(NOT HAVE_STRPTIME)
  return()
endif()

message(CHECK_START "Checking whether strptime() is declared")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  set(CMAKE_REQUIRED_QUIET TRUE)

  # Use invalid declaration to see if it fails to compile.
  check_source_compiles(C [[
    #include <time.h>
    int main(void)
    {
      int strptime(const char *s, const char *format, struct tm *tm);
      return 0;
    }
  ]] HAVE_STRPTIME_DECL)
cmake_pop_check_state()

if(NOT HAVE_STRPTIME_DECL)
  message(CHECK_PASS "yes")
  set(HAVE_STRPTIME_DECL_FAILS TRUE)
else()
  message(CHECK_FAIL "no")
endif()
