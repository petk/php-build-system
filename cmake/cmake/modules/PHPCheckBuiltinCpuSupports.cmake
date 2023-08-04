#[=============================================================================[
Checks whether compiler supports __builtin_cpu_supports.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CPU_SUPPORTS``
  Set to 1 if compiler supports __builtin_cpu_supports, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_cpu_supports")

check_c_source_compiles("
  int main (void) {
    return __builtin_cpu_supports(\"sse\")? 1 : 0;
  }
" have_builtin_cpu_supports)

if(have_builtin_cpu_supports)
  set(have_builtin_cpu_supports 1)
else()
  set(have_builtin_cpu_supports 0)
endif()

set(PHP_HAVE_BUILTIN_CPU_SUPPORTS ${have_builtin_cpu_supports} CACHE INTERNAL "Whether the compiler supports __builtin_cpu_supports")

unset(have_builtin_cpu_supports)
