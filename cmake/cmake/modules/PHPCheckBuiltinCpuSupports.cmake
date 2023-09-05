#[=============================================================================[
Checks whether compiler supports __builtin_cpu_supports.

Module sets the following variables:

PHP_HAVE_BUILTIN_CPU_SUPPORTS
  Set to true if compiler supports __builtin_cpu_supports, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_cpu_supports")

check_c_source_compiles("
  int main (void) {
    return __builtin_cpu_supports(\"sse\")? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CPU_SUPPORTS)
