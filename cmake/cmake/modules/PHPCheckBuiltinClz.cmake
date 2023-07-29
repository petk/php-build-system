#[=============================================================================[
Checks whether compiler supports __builtin_clz.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CLZ``
  Set to 1 if compiler supports __builtin_clz, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_clz")

check_c_source_compiles("
  int main (void) {
    return __builtin_clz(1) ? 1 : 0;
  }
" have_builtin_clz)

if(have_builtin_clz)
  set(have_builtin_clz 1)
else()
  set(have_builtin_clz 0)
endif()

set(PHP_HAVE_BUILTIN_CLZ ${have_builtin_clz} CACHE STRING "Whether the compiler supports __builtin_clz")
