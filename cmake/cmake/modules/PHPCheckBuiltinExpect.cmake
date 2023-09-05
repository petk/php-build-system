#[=============================================================================[
Checks whether compiler supports __builtin_expect.

Module sets the following variables:

PHP_HAVE_BUILTIN_EXPECT
  Set to true if compiler supports __builtin_expect, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_expect")

check_c_source_compiles("
  int main (void) {
    return __builtin_expect(1,1) ? 1 : 0;
  }
" PHP_HAVE_BUILTIN_EXPECT)
