#[=============================================================================[
Checks whether compiler supports __builtin_unreachable.

Module sets the following variables:

PHP_HAVE_BUILTIN_UNREACHABLE
  Set to true if compiler supports __builtin_unreachable, false otherwise.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_unreachable")

check_c_source_compiles("
  int main (void) {
    __builtin_unreachable();
    return 0;
  }
" PHP_HAVE_BUILTIN_UNREACHABLE)
