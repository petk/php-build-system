#[=============================================================================[
Checks whether compiler supports __builtin_cpu_init.

Module sets the following variables:

PHP_HAVE_BUILTIN_CPU_INIT
  Set to true if compiler supports __builtin_cpu_init, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_cpu_init")

check_c_source_compiles("
  int main (void) {
    return __builtin_cpu_init()? 1 : 0;
  }
" PHP_HAVE_BUILTIN_CPU_INIT)
