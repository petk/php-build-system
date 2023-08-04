#[=============================================================================[
Checks whether compiler supports __builtin_ctzll.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CTZLL``
  Set to 1 if compiler supports __builtin_ctzll, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_ctzll")

check_c_source_compiles("
  int main (void) {
    return __builtin_ctzll(2LL) ? 1 : 0;
  }
" have_builtin_ctzll)

if(have_builtin_ctzll)
  set(have_builtin_ctzll 1)
else()
  set(have_builtin_ctzll 0)
endif()

set(PHP_HAVE_BUILTIN_CTZLL ${have_builtin_ctzll} CACHE INTERNAL "Whether the compiler supports __builtin_ctzll")

unset(have_builtin_ctzll)
