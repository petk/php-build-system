#[=============================================================================[
Checks whether compiler supports __builtin_ssubll_overflow.

Module sets the following variables:

``PHP_HAVE_BUILTIN_SSUBLL_OVERFLOW``
  Set to 1 if compiler supports __builtin_ssubll_overflow, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_ssubll_overflow")

check_c_source_compiles("
  int main (void) {
    long long tmpvar;
    return __builtin_ssubll_overflow(3, 7, &tmpvar);
  }
" have_builtin_ssubll_overflow)

if(have_builtin_ssubll_overflow)
  set(have_builtin_ssubll_overflow 1)
else()
  set(have_builtin_ssubll_overflow 0)
endif()

set(PHP_HAVE_BUILTIN_SSUBLL_OVERFLOW ${have_builtin_ssubll_overflow} CACHE STRING "Whether the compiler supports __builtin_ssubll_overflow")
