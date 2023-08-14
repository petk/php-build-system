include(CheckCSourceCompiles)

option(sysvsem "Whether to enable the System V semaphore extension" OFF)

if(NOT sysvsem)
  return()
endif()

message(STATUS "Checking for union semun")

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/ipc.h>
  #include <sys/sem.h>

  int main()
  {
    union semun x;

    return 0;
  }
" HAVE_SEMUN)

if(HAVE_SEMUN)
  set(HAVE_SEMUN 1 CACHE INTERNAL "Whether union semun is supported")
else()
  set(HAVE_SEMUN 0 CACHE INTERNAL "Whether union semun is supported")
endif()

string(TOLOWER ${sysvsem} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "sysvsem" ${extension_library_type})

add_library(ext_sysvsem ${extension_library_type}
  sysvsem.c
)
