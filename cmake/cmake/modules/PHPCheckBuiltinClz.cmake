#[=============================================================================[
Checks whether compiler supports __builtin_clz.

Module sets the following variables:

PHP_HAVE_BUILTIN_CLZ
  Set to true if compiler supports __builtin_clz, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_clz")

check_c_source_compiles("
  int main (void) {
    return __builtin_clz(1) ? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CLZ)
