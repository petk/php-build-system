#[=============================================================================[
Determine the C standard library used for the build.

Result variables:
  PHP_C_STANDARD_LIBRARY
    Lowercase name of the C standard library:
    - glibc
    - musl
    - uclibc

Cache variables:
  __MUSL__
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking C standard library")

# The uClibc and its maintained fork uClibc-ng behave like minimalistic GNU C
# library but have differences. They can be determined by the __UCLIBC__ symbol
# and must be checked first because they also define the __GLIBC__ symbol.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__UCLIBC__ features.h _PHP_C_STANDARD_LIBRARY_UCLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_UCLIBC)
  set(PHP_C_STANDARD_LIBRARY "uclibc")
  message(CHECK_PASS "uClibc")
  return()
endif()

# The GNU C standard library has __GLIBC__ and __GLIBC_MINOR__ symbols since the
# very early version 2.0.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__GLIBC__ features.h _PHP_C_STANDARD_LIBRARY_GLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_GLIBC)
  set(PHP_C_STANDARD_LIBRARY "glibc")
  message(CHECK_PASS "GNU C (glibc)")
  return()
endif()

# The musl libc doesn't advertise itself with symbols, so it must be determined
# heuristically.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__DEFINED_va_list stdarg.h _PHP_C_STANDARD_LIBRARY_MUSL)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_MUSL)
  set(PHP_C_STANDARD_LIBRARY "musl")
else()
  # Otherwise, try determining musl libc with ldd.
  block(PROPAGATE PHP_C_STANDARD_LIBRARY)
    execute_process(
      COMMAND ldd --version
      OUTPUT_VARIABLE version
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(version MATCHES ".*musl libc.*")
      set(PHP_C_STANDARD_LIBRARY "musl")
    endif()
  endblock()
endif()
if(PHP_C_STANDARD_LIBRARY STREQUAL "musl")
  set(__MUSL__ 1 CACHE INTERNAL "Whether musl libc is used.")
  message(CHECK_PASS "musl")
  return()
endif()

message(CHECK_FAIL "unknown")
