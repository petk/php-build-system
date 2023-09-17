#[=============================================================================[
Detect the style of crypt_r() if any is available.
See Autoconf macro APR_CHECK_CRYPT_R_STYLE() from the APR project for the
original version.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking which data struct is used by crypt_r")

check_c_source_compiles("
  #define _REENTRANT 1
  #include <crypt.h>

  int main(void) {
    CRYPTD buffer;
    crypt_r(\"passwd\", \"hash\", &buffer);

    return 0;
  }
" CRYPT_R_CRYPTD)

if(CRYPT_R_CRYPTD)
  return()
endif()

check_c_source_compiles("
  #define _REENTRANT 1
  #include <crypt.h>

  int main(void) {
    struct crypt_data buffer;
    crypt_r(\"passwd\", \"hash\", &buffer);

    return 0;
  }
" CRYPT_R_STRUCT_CRYPT_DATA)

if(CRYPT_R_STRUCT_CRYPT_DATA)
  return()
endif()

check_c_source_compiles("
  #define _REENTRANT 1
  #define _GNU_SOURCE
  #include <crypt.h>

  int main(void) {
    struct crypt_data buffer;
    crypt_r(\"passwd\", \"hash\", &buffer);

    return0;
  }
" CRYPT_R_GNU_SOURCE)

if(CRYPT_R_GNU_SOURCE)
  set(CRYPT_R_STRUCT_CRYPT_DATA 1 CACHE INTERNAL "Define if crypt_r uses struct crypt_data")

  return()
endif()

check_c_source_compiles("
  #include <stdlib.h>
  #include <unistd.h>

  int main(void) {
    struct crypt_data buffer;
    crypt_r(\"passwd\", \"hash\", &buffer);

    return 0;
  }
" CRYPT_R_STRUCT_CRYPT_DATA)

if(CRYPT_R_STRUCT_CRYPT_DATA)
  return()
endif()

message(FATAL_ERROR "Unable to detect data struct used by crypt_r")
