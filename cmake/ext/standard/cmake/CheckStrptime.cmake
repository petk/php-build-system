#[=============================================================================[
Check strptime() and its declaration.

This check is obsolete. The PHP strptime() function is deprecated as of PHP
8.1.0 and strptime(), where available, simply needs the _GNU_SOURCE defined or
compiler flag -std=gnuXX appended to be declared in <time.h>.

Result variables:

* HAVE_STRPTIME
* HAVE_DECL_STRPTIME
#]=============================================================================]

include(CheckFunctionExists)
include(CheckSymbolExists)
include(CMakePushCheckState)

if(PHP_VERSION VERSION_GREATER_EQUAL 9.0)
  message(
    DEPRECATION
    "${CMAKE_CURRENT_LIST_FILE} is obsolete and should be removed. The PHP "
    "strptime() function is deprecated as of PHP 8.1.0."
  )
endif()

set(HAVE_STRPTIME FALSE)
set(HAVE_DECL_STRPTIME FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(strptime time.h PHP_HAS_STRPTIME)
cmake_pop_check_state()

if(PHP_HAS_STRPTIME)
  set(HAVE_STRPTIME TRUE)
  set(HAVE_DECL_STRPTIME TRUE)
  return()
endif()

# Check if linker sees the function.
check_function_exists(strptime PHP_HAS_STRPTIME_FUNCTION)

if(PHP_HAS_STRPTIME_FUNCTION)
  set(HAVE_STRPTIME TRUE)
endif()
