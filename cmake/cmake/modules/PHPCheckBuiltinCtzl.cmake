#[=============================================================================[
Checks whether compiler supports __builtin_ctzl.

Module sets the following variables:

PHP_HAVE_BUILTIN_CTZL
  Set to true if compiler supports __builtin_ctzl, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_ctzl")

check_c_source_compiles("
  int main (void) {
    return __builtin_ctzl(2L) ? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CTZL)
