#[=============================================================================[
Checks whether compiler supports __builtin_expect.

Module sets the following variables:

``PHP_HAVE_BUILTIN_EXPECT``
  Set to 1 if compiler supports __builtin_expect, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_expect")

check_c_source_compiles("
  int main (void) {
    return __builtin_expect(1,1) ? 1 : 0;
  }
" have_builtin_expect)

if(have_builtin_expect)
  set(have_builtin_expect 1)
else()
  set(have_builtin_expect 0)
endif()

set(PHP_HAVE_BUILTIN_EXPECT ${have_builtin_expect} CACHE STRING "Whether the compiler supports __builtin_expect")
