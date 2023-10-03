#[=============================================================================[
Check if PHP can use external libcrypt.

Module sets the following variables:

HAVE_CRYPT
  Set to 1 if crypt function is available.

CRYPT_EXTRA_LIBRARIES
  A list of additional libraries for building the target.

HAVE_CRYPT_R
  Set to 1 if crypt_r is available.
]=============================================================================]#

include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)

set(CRYPT_EXTRA_LIBRARIES "" CACHE INTERNAL "Additional libraries to pass to target")

check_symbol_exists(crypt "crypt.h" HAVE_CRYPT)

if(NOT HAVE_CRYPT)
  check_library_exists(crypt crypt "" HAVE_CRYPT)
  if(NOT HAVE_CRYPT)
    message(FATAL_ERROR "Crypt library not found")
  endif()

  list(APPEND CRYPT_EXTRA_LIBRARIES ${CRYPT_EXTRA_LIBRARIES} crypt)
endif()

check_symbol_exists(crypt_r "crypt.h" HAVE_CRYPT_R)

if(NOT HAVE_CRYPT_R)
  check_library_exists(crypt crypt_r "" HAVE_CRYPT_R)

  if(HAVE_CRYPT_R)
    list(APPEND CRYPT_EXTRA_LIBRARIES ${CRYPT_EXTRA_LIBRARIES} crypt)
  endif()
endif()

# Check crypt_r() style.
if(HAVE_CRYPT_R)
  include(PHP/CheckExternalLibcrypt/CheckCryptRStyle)
endif()

check_include_file(crypt.h HAVE_CRYPT_H)

set(_libcrypt_extra_definitions "")

if(HAVE_UNISTD_H)
  list(APPEND _libcrypt_extra_definitions -DHAVE_UNISTD_H=1)
endif()

if(HAVE_CRYPT_H)
  list(APPEND _libcrypt_extra_definitions -DHAVE_CRYPT_H=1)
endif()

message(STATUS "Checking for standard DES crypt")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "yes (cross-compiling)")
  set(_crypt_des ON)
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS ${_libcrypt_extra_definitions})

    check_c_source_runs("
      #include <string.h>

      #if HAVE_UNISTD_H
      #include <unistd.h>
      #endif

      #if HAVE_CRYPT_H
      #include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void) {
      #if HAVE_CRYPT
        char *encrypted = crypt(\"rasmuslerdorf\",\"rl\");
        return !encrypted || strcmp(encrypted,\"rl.3StKT.4T8M\");
      #else
        return 1;
      #endif
      }
    " _crypt_des)
  cmake_pop_check_state()
endif()

message(STATUS "Checking for extended DES crypt")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS ${_libcrypt_extra_definitions})

    check_c_source_runs("
      #include <string.h>

      #if HAVE_UNISTD_H
      #include <unistd.h>
      #endif

      #if HAVE_CRYPT_H
      #include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void) {
      #if HAVE_CRYPT
        char *encrypted = crypt(\"rasmuslerdorf\",\"_J9..rasm\");
        return !encrypted || strcmp(encrypted,\"_J9..rasmBYk8r9AiWNc\");
      #else
        return 1;
      #endif
      }
    " _crypt_ext_des)
  cmake_pop_check_state()
endif()

message(STATUS "Checking for MD5 crypt")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS ${_libcrypt_extra_definitions})

    check_c_source_runs("
      #include <string.h>

      #if HAVE_UNISTD_H
      #include <unistd.h>
      #endif

      #if HAVE_CRYPT_H
      #include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void) {
      #if HAVE_CRYPT
        char salt[15], answer[40];
        char *encrypted;

        salt[0]='$'; salt[1]='1'; salt[2]='$';
        salt[3]='r'; salt[4]='a'; salt[5]='s';
        salt[6]='m'; salt[7]='u'; salt[8]='s';
        salt[9]='l'; salt[10]='e'; salt[11]='$';
        salt[12]='\\\\0';
        strcpy(answer,salt);
        strcat(answer,\"rISCgZzpwk3UhDidwXvin0\");
        encrypted = crypt(\"rasmuslerdorf\",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    " _crypt_md5)
  cmake_pop_check_state()
endif()

message(STATUS "Checking for Blowfish crypt")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS ${_libcrypt_extra_definitions})

    check_c_source_runs("
      #include <string.h>

      #if HAVE_UNISTD_H
      #include <unistd.h>
      #endif

      #if HAVE_CRYPT_H
      #include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void) {
      #if HAVE_CRYPT
        char salt[30], answer[70];
        char *encrypted;

        salt[0]='$'; salt[1]='2'; salt[2]='a'; salt[3]='$'; salt[4]='0'; salt[5]='7'; salt[6]='$'; salt[7]='\\\\0';
        strcat(salt,\"rasmuslerd............\");
        strcpy(answer,salt);
        strcpy(&answer[29],\"nIdrcHdxcUxWomQX9j6kvERCFjTg7Ra\");
        encrypted = crypt(\"rasmuslerdorf\",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    " _crypt_blowfish)
  cmake_pop_check_state()
endif()

message(STATUS "Checking for SHA512 crypt")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS ${_libcrypt_extra_definitions})

    check_c_source_runs("
      #include <string.h>

      #if HAVE_UNISTD_H
      #include <unistd.h>
      #endif

      #if HAVE_CRYPT_H
      #include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void) {
      #if HAVE_CRYPT
        char salt[21], answer[21+86];
        char *encrypted;

        strcpy(salt,\"\\\\$6\\\\$rasmuslerdorf\\\\$\");
        strcpy(answer, salt);
        strcat(answer, \"EeHCRjm0bljalWuALHSTs1NB9ipEiLEXLhYeXdOpx22gmlmVejnVXFhd84cEKbYxCo.XuUTrW.RLraeEnsvWs/\");
        encrypted = crypt(\"rasmuslerdorf\",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    " _crypt_sha512)
  cmake_pop_check_state()
endif()

message(STATUS "Checking for SHA256 crypt")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS ${_libcrypt_extra_definitions})

    check_c_source_runs("
      #include <string.h>

      #if HAVE_UNISTD_H
      #include <unistd.h>
      #endif

      #if HAVE_CRYPT_H
      #include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void) {
      #if HAVE_CRYPT
        char salt[21], answer[21+43];
        char *encrypted;

        strcpy(salt,\"\\\\$5\\\\$rasmuslerdorf\\\\$\");
        strcpy(answer, salt);
        strcat(answer, \"cFAm2puLCujQ9t.0CxiFIIvFi4JyQx5UncCt/xRIX23\");
        encrypted = crypt(\"rasmuslerdorf\",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    " _crypt_sha256)
  cmake_pop_check_state()
endif()

if(NOT _crypt_des OR NOT _crypt_ext_des OR NOT _crypt_md5 OR NOT _crypt_blowfish OR NOT _crypt_sha512 OR NOT _crypt_sha256 OR NOT HAVE_CRYPT_R)
  message(FATAL_ERROR "Cannot use external libcrypt as some algos are missing")
endif()

list(REMOVE_DUPLICATES ${CRYPT_EXTRA_LIBRARIES})
