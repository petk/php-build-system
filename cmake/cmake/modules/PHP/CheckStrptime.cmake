#[=============================================================================[
Check strptime() and its declaration.

Note: This module is obsolete. PHP strptime() is deprecated as of PHP 8.1.0.

Cache variables:

  HAVE_STRPTIME
    Whether strptime() is available.

Result variables:

  HAVE_DECL_STRPTIME
    Whether strptime() is declared.

#]=============================================================================]

include_guard(GLOBAL)

include(CheckFunctionExists)
include(CheckSymbolExists)
include(CMakePushCheckState)

# Check whether linker sees the strptime and it is declared in time.h.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(strptime "time.h" HAVE_STRPTIME)
cmake_pop_check_state()

if(HAVE_STRPTIME)
  set(HAVE_DECL_STRPTIME 1)
  return()
endif()

# The rest of this module is obsolete because strptime(), where available,
# simply needs the _GNU_SOURCE defined or compiler flag -std=gnuXX appended to
# be declared in time.h.

# Check if linker sees the function.
unset(HAVE_STRPTIME CACHE)
check_function_exists(strptime HAVE_STRPTIME)
