#[=============================================================================[
Determine C standard library that will be used for the build.

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

# Initial uClibc and its maintained fork uClibc-ng behave like minimalistic GNU
# C but aren't. These can be determined by the __UCLIBC__ symbol. They must be
# checked first because they also define the __GLIBC__ symbol.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__UCLIBC__ features.h _PHP_C_STANDARD_LIBRARY_UCLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_UCLIBC)
  set(PHP_C_STANDARD_LIBRARY "uclibc")
  message(CHECK_PASS "uClibc")
  return()
endif()

# GNU C standard library has __GLIBC__ and __GLIBC_MINOR__ symbols synce the
# very early versions 2.0.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__GLIBC__ features.h _PHP_C_STANDARD_LIBRARY_GLIBC)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_GLIBC)
  set(PHP_C_STANDARD_LIBRARY "glibc")
  message(CHECK_PASS "GNU C (glibc)")
  return()
endif()

# The musl libc doesn't advertise itself specifically via symbols, so it must
# be guessed.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(__DEFINED_va_list stdarg.h _PHP_C_STANDARD_LIBRARY_MUSL)
cmake_pop_check_state()
if(_PHP_C_STANDARD_LIBRARY_MUSL)
  set(PHP_C_STANDARD_LIBRARY "musl")
  message(CHECK_PASS "musl")
  return()
endif()

# Otherwise, try using ldd.
block(PROPAGATE PHP_C_STANDARD_LIBRARY)
  execute_process(
    COMMAND ldd --version
    OUTPUT_VARIABLE version
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(version MATCHES ".*musl libc.*")
    set(__MUSL__ 1 CACHE INTERNAL "Whether musl libc is used")
    set(PHP_C_STANDARD_LIBRARY "musl")
    message(CHECK_PASS "musl")
    return()
  endif()
endblock()

message(CHECK_FAIL "unknown")
