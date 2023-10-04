#[=============================================================================[
Check for missing declarations of reentrant functions.

Module sets the following variables:

MISSING_LOCALTIME_R_DECL
  Set to 1 if localtime_r is not declared.
MISSING_GMTIME_R_DECL
  Set to 1 if gmtime_r is not declared.
MISSING_ASCTIME_R_DECL
  Set to 1 if asctime_r is not declared.
MISSING_CTIME_R_DECL
  Set to 1 if ctime_r is not declared.
MISSING_STRTOK_R_DECL
  Set to 1 if strtok_r is not declared.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for missing declarations of reentrant functions")

check_c_source_compiles("
  #include <time.h>

  int main(void) {
    struct tm *(*func)() = localtime_r;
    return 0;
  }
" _have_localtime_r)

if(NOT _have_localtime_r)
  set(MISSING_LOCALTIME_R_DECL 1 CACHE INTERNAL "Whether localtime_r is declared")
endif()

check_c_source_compiles("
  #include <time.h>

  int main(void) {
    struct tm *(*func)() = gmtime_r;
    return 0;
  }
" _have_gm_time_r)

if(NOT _have_gm_time_r)
  set(MISSING_GMTIME_R_DECL 1 CACHE INTERNAL "Whether gmtime_r is declared")
endif()

check_c_source_compiles("
  #include <time.h>

  int main(void) {
    char *(*func)() = asctime_r;
    return 0;
  }
" _have_asctime_r)

if(NOT _have_asctime_r)
  set(MISSING_ASCTIME_R_DECL 1 CACHE INTERNAL "Whether asctime_r is declared")
endif()

check_c_source_compiles("
  #include <time.h>

  int main(void) {
    char *(*func)() = ctime_r;
    return 0;
  }
" _have_ctime_r)

if(NOT _have_ctime_r)
  set(MISSING_CTIME_R_DECL 1 CACHE INTERNAL "Whether ctime_r is declared")
endif()

check_c_source_compiles("
  #include <string.h>

  int main(void) {
    char *(*func)() = strtok_r;
    return 0;
  }
" _have_strtok_r)

if(NOT _have_strtok_r)
  set(MISSING_STRTOK_R_DECL 1 CACHE INTERNAL "Whether strtok_r is declared")
endif()
