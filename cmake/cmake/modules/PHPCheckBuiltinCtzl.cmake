#[=============================================================================[
Checks whether compiler supports __builtin_ctzl.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CTZL``
  Set to 1 if compiler supports __builtin_ctzl, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_ctzl")

check_c_source_compiles("
  int main (void) {
    return __builtin_ctzl(2L) ? 1 : 0;
  }
" have_builtin_ctzl)

if(have_builtin_ctzl)
  set(have_builtin_ctzl 1)
else()
  set(have_builtin_ctzl 0)
endif()

set(PHP_HAVE_BUILTIN_CTZL ${have_builtin_ctzl} CACHE INTERNAL "Whether the compiler supports __builtin_ctzl")

unset(have_builtin_ctzl)
