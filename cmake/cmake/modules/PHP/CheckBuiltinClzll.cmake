#[=============================================================================[
Checks whether compiler supports __builtin_clzll.

Module sets the following variables:

PHP_HAVE_BUILTIN_CLZLL
  Set to true if compiler supports __builtin_clzll, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_clzll")

check_c_source_compiles("
  int main (void) {
    return __builtin_clzll(1) ? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CLZLL)
