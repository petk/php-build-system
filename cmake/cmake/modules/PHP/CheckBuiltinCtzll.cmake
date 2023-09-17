#[=============================================================================[
Checks whether compiler supports __builtin_ctzll.

Module sets the following variables:

PHP_HAVE_BUILTIN_CTZLL
  Set to true if compiler supports __builtin_ctzll, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_ctzll")

check_c_source_compiles("
  int main (void) {
    return __builtin_ctzll(2LL) ? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CTZLL)
