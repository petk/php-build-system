#[=============================================================================[
Checks whether compiler supports __builtin_clzll.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CLZLL``
  Set to 1 if compiler supports __builtin_clzll, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_clzll")

check_c_source_compiles("
  int main (void) {
    return __builtin_clzll(1) ? 1 : 0;
  }
" have_builtin_clzll)

if(have_builtin_clzll)
  set(have_builtin_clzll 1)
else()
  set(have_builtin_clzll 0)
endif()

set(PHP_HAVE_BUILTIN_CLZLL ${have_builtin_clzll} CACHE INTERNAL "Whether the compiler supports __builtin_clzll")

unset(have_builtin_clzll)
