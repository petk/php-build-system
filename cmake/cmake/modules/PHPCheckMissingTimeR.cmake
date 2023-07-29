#[=============================================================================[
Checks for missing declarations of reentrant functions.

Module sets the following variables:

MISSING_LOCALTIME_R_DECL
MISSING_GMTIME_R_DECL
MISSING_ASCTIME_R_DECL
MISSING_CTIME_R_DECL
MISSING_STRTOK_R_DECL
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for missing declarations of reentrant functions")

check_c_source_compiles("
  #include <time.h>

  int main() {
    struct tm *(*func)() = localtime_r;
    return 0;
  }
" have_localtime_r)

if(NOT have_localtime_r)
  set(MISSING_LOCALTIME_R_DECL 1 CACHE STRING "Whether localtime_r is declared")
endif()

check_c_source_compiles("
  #include <time.h>

  int main() {
    struct tm *(*func)() = gmtime_r;
    return 0;
  }
" have_gm_time_r)

if(NOT have_gm_time_r)
  set(MISSING_GMTIME_R_DECL 1 CACHE STRING "Whether gmtime_r is declared")
endif()

check_c_source_compiles("
  #include <time.h>

  int main() {
    char *(*func)() = asctime_r;
    return 0;
  }
" have_asctime_r)

if(NOT have_asctime_r)
  set(MISSING_ASCTIME_R_DECL 1 CACHE STRING "Whether asctime_r is declared")
endif()

check_c_source_compiles("
  #include <time.h>

  int main() {
    char *(*func)() = ctime_r;
    return 0;
  }
" have_ctime_r)

if(NOT have_ctime_r)
  set(MISSING_CTIME_R_DECL 1 CACHE STRING "Whether ctime_r is declared")
endif()

check_c_source_compiles("
  #include <string.h>

  int main() {
    char *(*func)() = strtok_r;
    return 0;
  }
" have_strtok_r)

if(NOT have_strtok_r)
  set(MISSING_STRTOK_R_DECL 1 CACHE STRING "Whether strtok_r is declared")
endif()
