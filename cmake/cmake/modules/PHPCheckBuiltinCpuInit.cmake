#[=============================================================================[
Checks whether compiler supports __builtin_cpu_init.

Module sets the following variables:

``PHP_HAVE_BUILTIN_CPU_INIT``
  Set to 1 if compiler supports __builtin_cpu_init, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_cpu_init")

check_c_source_compiles("
  int main (void) {
    return __builtin_cpu_init()? 1 : 0;
  }
" have_builtin_cpu_init)

if(have_builtin_cpu_init)
  set(have_builtin_cpu_init 1)
else()
  set(have_builtin_cpu_init 0)
endif()

set(PHP_HAVE_BUILTIN_CPU_INIT ${have_builtin_cpu_init} CACHE INTERNAL "Whether the compiler supports __builtin_cpu_init")

unset(have_builtin_cpu_init)
