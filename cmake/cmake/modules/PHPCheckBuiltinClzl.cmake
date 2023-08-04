#[=============================================================================[
Checks whether compiler supports __builtin_clzl.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CLZL``
  Set to 1 if compiler supports __builtin_clzl, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_clzl")

check_c_source_compiles("
  int main (void) {
    return __builtin_clzl(1) ? 1 : 0;
  }
" have_builtin_clzl)

if(have_builtin_clzl)
  set(have_builtin_clzl 1)
else()
  set(have_builtin_clzl 0)
endif()

set(PHP_HAVE_BUILTIN_CLZL ${have_builtin_clzl} CACHE INTERNAL "Whether the compiler supports __builtin_clzl")

unset(have_builtin_clzl)
