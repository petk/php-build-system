#[=============================================================================[
Checks whether compiler supports __builtin_saddl_overflow.

Module sets the following variables:

PHP_HAVE_BUILTIN_SADDL_OVERFLOW
  Set to true if compiler supports __builtin_saddl_overflow, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_saddl_overflow")

check_c_source_compiles("
  int main (void) {
    long tmpvar;
    return __builtin_saddl_overflow(3, 7, &tmpvar);
  }
" PHP_HAVE_BUILTIN_SADDL_OVERFLOW)
