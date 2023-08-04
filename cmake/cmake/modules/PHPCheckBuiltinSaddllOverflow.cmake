#[=============================================================================[
Checks whether compiler supports __builtin_saddll_overflow.

Module sets the following variables:

``PHP_HAVE_BUILTIN_SADDLL_OVERFLOW``
  Set to 1 if compiler supports __builtin_saddll_overflow, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_saddll_overflow")

check_c_source_compiles("
  int main (void) {
    long long tmpvar;
    return __builtin_saddll_overflow(3, 7, &tmpvar);
  }
" have_builtin_saddll_overflow)

if(have_builtin_saddll_overflow)
  set(have_builtin_saddll_overflow 1)
else()
  set(have_builtin_saddll_overflow 0)
endif()

set(PHP_HAVE_BUILTIN_SADDLL_OVERFLOW ${have_builtin_saddll_overflow} CACHE INTERNAL "Whether the compiler supports __builtin_saddll_overflow")

unset(have_builtin_saddll_overflow)
