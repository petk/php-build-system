#[=============================================================================[
Find the crypt library and run a set of checks for PHP to use the crypt library.

Module defines the following IMPORTED targets:

  Crypt::Crypt
    The crypt library, if found.

Result variables:

  Crypt_FOUND
    Whether crypt has been found.
  Crypt_INCLUDE_DIRS
    A list of include directories for using crypt library.
  Crypt_LIBRARIES
    A list of libraries for linking when using crypt library.

Cache variables:
  HAVE_CRYPT_H
  HAVE_CRYPT
  HAVE_CRYPT_R
  CRYPT_R_CRYPTD
  CRYPT_R_STRUCT_CRYPT_DATA
  CRYPT_R_GNU_SOURCE
#]=============================================================================]

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CMakePushCheckState)
include(FindPackageHandleStandardArgs)
include(PHP/SearchLibraries)

set_package_properties(Crypt PROPERTIES
  DESCRIPTION "Crypt library"
)

################################################################################
# Module helpers.
################################################################################

# Detect the style of crypt_r() if any is available. See Autoconf macro
# APR_CHECK_CRYPT_R_STYLE() from the APR project for the original version.
function(_crypt_check_crypt_r_style library)
  set(CRYPT_R_WORKS TRUE PARENT_SCOPE)

  message(CHECK_START "Checking which data struct is used by crypt_r")

  cmake_push_check_state(RESET)
    if(library)
      set(CMAKE_REQUIRED_LIBRARIES ${library})
    endif()

    check_c_source_compiles([[
      #define _REENTRANT 1
      #include <crypt.h>

      int main(void) {
        CRYPTD buffer;
        crypt_r("passwd", "hash", &buffer);

        return 0;
      }
    ]] CRYPT_R_CRYPTD)

    if(CRYPT_R_CRYPTD)
      message(CHECK_PASS "cryptd")
      cmake_pop_check_state()
      return()
    endif()

    check_c_source_compiles([[
      #define _REENTRANT 1
      #include <crypt.h>

      int main(void) {
        struct crypt_data buffer;
        crypt_r("passwd", "hash", &buffer);

        return 0;
      }
    ]] CRYPT_R_STRUCT_CRYPT_DATA)

    if(CRYPT_R_STRUCT_CRYPT_DATA)
      message(CHECK_PASS "struct crypt_data")
      cmake_pop_check_state()
      return()
    endif()

    check_c_source_compiles([[
      #define _REENTRANT 1
      #define _GNU_SOURCE
      #include <crypt.h>

      int main(void) {
        struct crypt_data buffer;
        crypt_r("passwd", "hash", &buffer);

        return 0;
      }
    ]] CRYPT_R_GNU_SOURCE)

    if(CRYPT_R_GNU_SOURCE)
      set(
        CRYPT_R_STRUCT_CRYPT_DATA 1
        CACHE INTERNAL "Define if crypt_r uses struct crypt_data"
      )

      message(CHECK_PASS "GNU struct crypt_data")
      cmake_pop_check_state()
      return()
    endif()

    check_c_source_compiles([[
      #include <stdlib.h>
      #include <unistd.h>

      int main(void) {
        struct crypt_data buffer;
        crypt_r("passwd", "hash", &buffer);

        return 0;
      }
    ]] _CRYPT_R_STRUCT_CRYPT_DATA)

    if(_CRYPT_R_STRUCT_CRYPT_DATA)
      set(
        CRYPT_R_STRUCT_CRYPT_DATA 1
        CACHE INTERNAL "Define if crypt_r uses struct crypt_data"
      )

      message(CHECK_PASS "struct crypt_data")
      cmake_pop_check_state()
      return()
    endif()

  cmake_pop_check_state()

  message(CHECK_FAIL "none")

  set(CRYPT_R_WORKS FALSE PARENT_SCOPE)
endfunction()

################################################################################
# Configure checks.
################################################################################

check_include_file(crypt.h HAVE_CRYPT_H)

find_path(Crypt_INCLUDE_DIRS crypt.h)

php_search_libraries(
  crypt
  "crypt.h"
  HAVE_CRYPT
  CRYPT_LIBRARY
  LIBRARIES crypt
)

if(CRYPT_LIBRARY)
  list(APPEND Crypt_LIBRARIES ${CRYPT_LIBRARY})
endif()

php_search_libraries(
  crypt_r
  "crypt.h"
  HAVE_CRYPT_R
  CRYPT_R_LIBRARY
  LIBRARIES crypt
)

set(_reason_failure_message)

if(NOT HAVE_CRYPT_R)
  string(
    APPEND _reason_failure_message
    "\n    Required crypt_r could not be found."
  )
endif()

if(CRYPT_R_LIBRARY)
  list(APPEND Crypt_LIBRARIES ${CRYPT_R_LIBRARY})
endif()

_crypt_check_crypt_r_style(${CRYPT_R_LIBRARY})

if(NOT CRYPT_R_WORKS)
  string(
    APPEND _reason_failure_message
    "\n    Unable to detect data struct used by crypt_r."
  )
endif()

################################################################################
# Check if external libcrypt is usable.
################################################################################
cmake_push_check_state(RESET)
  if(HAVE_UNISTD_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H=1)
  endif()

  if(HAVE_CRYPT_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_CRYPT_H=1)
  endif()

  if(HAVE_CRYPT)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_CRYPT=1)
  endif()

  if(CRYPT_LIBRARY OR CRYPT_R_LIBRARY)
    list(APPEND CMAKE_REQUIRED_LIBRARIES ${CRYPT_LIBRARY} ${CRYPT_R_LIBRARY})
  endif()

  message(CHECK_START "Checking for standard DES crypt")

  if(CMAKE_CROSSCOMPILING)
    message(CHECK_PASS "yes (cross-compiling)")
    set(_crypt_des ON)
  else()
    check_c_source_runs([[
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
        char *encrypted = crypt("rasmuslerdorf","rl");
        return !encrypted || strcmp(encrypted,"rl.3StKT.4T8M");
      #else
        return 1;
      #endif
      }
    ]] _crypt_des)

    if(_crypt_des)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  message(CHECK_START "Checking for extended DES crypt")

  if(CMAKE_CROSSCOMPILING)
    message(CHECK_FAIL "no (cross-compiling)")
  else()
    check_c_source_runs([[
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
        char *encrypted = crypt("rasmuslerdorf","_J9..rasm");
        return !encrypted || strcmp(encrypted,"_J9..rasmBYk8r9AiWNc");
      #else
        return 1;
      #endif
      }
    ]] _crypt_ext_des)

    if(_crypt_ext_des)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  message(CHECK_START "Checking for MD5 crypt")

  if(CMAKE_CROSSCOMPILING)
    message(CHECK_FAIL "no (cross-compiling)")
  else()
    check_c_source_runs([[
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
        salt[12]='\\0';
        strcpy(answer,salt);
        strcat(answer,"rISCgZzpwk3UhDidwXvin0");
        encrypted = crypt("rasmuslerdorf",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    ]] _crypt_md5)

    if(_crypt_md5)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  message(CHECK_START "Checking for Blowfish crypt")

  if(CMAKE_CROSSCOMPILING)
    message(CHECK_FAIL "no (cross-compiling)")
  else()
    check_c_source_runs([[
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

        salt[0]='$'; salt[1]='2'; salt[2]='a'; salt[3]='$';
        salt[4]='0'; salt[5]='7'; salt[6]='$'; salt[7]='\\0';
        strcat(salt,"rasmuslerd............");
        strcpy(answer,salt);
        strcpy(&answer[29],"nIdrcHdxcUxWomQX9j6kvERCFjTg7Ra");
        encrypted = crypt("rasmuslerdorf",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    ]] _crypt_blowfish)

    if(_crypt_blowfish)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  message(CHECK_START "Checking for SHA512 crypt")

  if(CMAKE_CROSSCOMPILING)
    message(CHECK_FAIL "no (cross-compiling)")
  else()
    check_c_source_runs([[
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

        strcpy(salt,"$6$rasmuslerdorf$");
        strcpy(answer, salt);
        strcat(answer, "EeHCRjm0bljalWuALHSTs1NB9ipEiLEXLhYeXdOpx22gmlmVejnVXFhd84cEKbYxCo.XuUTrW.RLraeEnsvWs/");
        encrypted = crypt("rasmuslerdorf",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    ]] _crypt_sha512)

    if(_crypt_sha512)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  message(CHECK_START "Checking for SHA256 crypt")

  if(CMAKE_CROSSCOMPILING)
    message(CHECK_FAIL "no (cross-compiling)")
  else()
    check_c_source_runs([[
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

        strcpy(salt,"$5$rasmuslerdorf$");
        strcpy(answer, salt);
        strcat(answer, "cFAm2puLCujQ9t.0CxiFIIvFi4JyQx5UncCt/xRIX23");
        encrypted = crypt("rasmuslerdorf",salt);
        return !encrypted || strcmp(encrypted,answer);
      #else
        return 1;
      #endif
      }
    ]] _crypt_sha256)

    if(_crypt_sha256)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()
cmake_pop_check_state()

if(
  NOT _crypt_des
  OR NOT _crypt_ext_des
  OR NOT _crypt_md5
  OR NOT _crypt_blowfish
  OR NOT _crypt_sha512
  OR NOT _crypt_sha256
)
  string(
    APPEND _reason_failure_message
    "\n    Cannot use external crypt library as some algos are missing."
  )
endif()

################################################################################
# Handle find_package arguments.
################################################################################

find_package_handle_standard_args(
  Crypt
  REQUIRED_VARS
    Crypt_LIBRARIES
    Crypt_INCLUDE_DIRS
    HAVE_CRYPT_R
    CRYPT_R_WORKS
    _crypt_des
    _crypt_ext_des
    _crypt_md5
    _crypt_blowfish
    _crypt_sha512
    _crypt_sha256
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)
unset(CRYPT_R_WORKS)

if(NOT Crypt_FOUND)
  return()
endif()

if(NOT TARGET Crypt::Crypt)
  add_library(Crypt::Crypt INTERFACE IMPORTED)

  set_target_properties(Crypt::Crypt PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Crypt_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Crypt_LIBRARIES}"
  )
endif()
