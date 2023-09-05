#[=============================================================================[
Checks whether compiler supports __builtin_clzl.

Module sets the following variables:

PHP_HAVE_BUILTIN_CLZL
  Set to true if compiler supports __builtin_clzl, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_clzl")

check_c_source_compiles("
  int main (void) {
    return __builtin_clzl(1) ? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CLZL)
