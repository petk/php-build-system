#[=============================================================================[
Check for missing declarations of reentrant functions.

Cache variables:

  MISSING_LOCALTIME_R_DECL
    Whether localtime_r is not declared.
  MISSING_GMTIME_R_DECL
    Whether gmtime_r is not declared.
  MISSING_ASCTIME_R_DECL
    Whether asctime_r is not declared.
  MISSING_CTIME_R_DECL
    Whether ctime_r is not declared.
  MISSING_STRTOK_R_DECL
    Whether strtok_r is not declared.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)

message(STATUS "Checking for missing declarations of reentrant functions")

check_source_compiles(C "
  #include <time.h>

  int main(void) {
    struct tm *(*func)() = localtime_r;
    return 0;
  }
" _have_localtime_r)

if(NOT _have_localtime_r)
  set(MISSING_LOCALTIME_R_DECL 1 CACHE INTERNAL "Whether localtime_r is declared")
endif()

check_source_compiles(C "
  #include <time.h>

  int main(void) {
    struct tm *(*func)() = gmtime_r;
    return 0;
  }
" _have_gm_time_r)

if(NOT _have_gm_time_r)
  set(MISSING_GMTIME_R_DECL 1 CACHE INTERNAL "Whether gmtime_r is declared")
endif()

check_source_compiles(C "
  #include <time.h>

  int main(void) {
    char *(*func)() = asctime_r;
    return 0;
  }
" _have_asctime_r)

if(NOT _have_asctime_r)
  set(MISSING_ASCTIME_R_DECL 1 CACHE INTERNAL "Whether asctime_r is declared")
endif()

check_source_compiles(C "
  #include <time.h>

  int main(void) {
    char *(*func)() = ctime_r;
    return 0;
  }
" _have_ctime_r)

if(NOT _have_ctime_r)
  set(MISSING_CTIME_R_DECL 1 CACHE INTERNAL "Whether ctime_r is declared")
endif()

check_source_compiles(C "
  #include <string.h>

  int main(void) {
    char *(*func)() = strtok_r;
    return 0;
  }
" _have_strtok_r)

if(NOT _have_strtok_r)
  set(MISSING_STRTOK_R_DECL 1 CACHE INTERNAL "Whether strtok_r is declared")
endif()
