#[=============================================================================[
Checks whether compiler supports __builtin_saddll_overflow.

Module sets the following variables:

PHP_HAVE_BUILTIN_SADDLL_OVERFLOW
  Set to true if compiler supports __builtin_saddll_overflow, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_saddll_overflow")

check_c_source_compiles("
  int main (void) {
    long long tmpvar;
    return __builtin_saddll_overflow(3, 7, &tmpvar);
  }
" PHP_HAVE_BUILTIN_SADDLL_OVERFLOW)
