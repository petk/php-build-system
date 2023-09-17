#[=============================================================================[
Checks whether compiler supports __builtin_usub_overflow.

Module sets the following variables:

PHP_HAVE_BUILTIN_USUB_OVERFLOW
  Set to true if compiler supports __builtin_usub_overflow, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_usub_overflow")

check_c_source_compiles("
  int main (void) {
    unsigned int tmpvar;
    return __builtin_usub_overflow(3, 7, &tmpvar);
  }
" PHP_HAVE_BUILTIN_USUB_OVERFLOW)
