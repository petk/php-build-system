include(CheckCSourceCompiles)
include(CMakeDependentOption)

option(EXT_SYSVSEM "Enable the sysvsem extension (System V semaphore)" OFF)

cmake_dependent_option(
  EXT_SYSVSEM_SHARED
  "Build the sysvsem extension as a shared library"
  OFF
  "EXT_SYSVSEM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVSEM)
  return()
endif()

if(EXT_SYSVSEM_SHARED)
  add_library(php_sysvsem SHARED)
else()
  add_library(php_sysvsem)
endif()

target_sources(php_sysvsem PRIVATE
  sysvsem.c
)

message(STATUS "Checking for union semun")

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/ipc.h>
  #include <sys/sem.h>

  int main(void) {
    union semun x;

    return 0;
  }
" HAVE_SEMUN)
