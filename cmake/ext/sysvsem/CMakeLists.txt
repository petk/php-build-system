include(CheckCSourceCompiles)
include(CMakeDependentOption)

option(EXT_SYSVSEM "Whether to enable the System V semaphore extension" OFF)

cmake_dependent_option(EXT_SYSVSEM_SHARED "Whether to build the sysvsem extension as shared object" OFF "EXT_SYSVSEM;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SYSVSEM)
  return()
endif()

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

if(EXT_SYSVSEM_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "sysvsem" ${_library_type})

add_library(ext_sysvsem ${_library_type}
  sysvsem.c
)
