#[=============================================================================[
# CheckCrypt

Check whether the `crypt` library works as expected for PHP by running a set of
PHP-specific checks.

## Cache variables

* `HAVE_CRYPT_H`
* `HAVE_CRYPT`
* `HAVE_CRYPT_R`
* `CRYPT_R_CRYPTD`
* `CRYPT_R_STRUCT_CRYPT_DATA`
* `CRYPT_R_GNU_SOURCE`
#]=============================================================================]

include_guard(GLOBAL)

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

# Check whether crypt() and crypt_r() are available.
function(_php_check_crypt)
  message(CHECK_START "Checking basic crypt functionality")

  unset(HAVE_CRYPT_H CACHE)
  unset(HAVE_CRYPT CACHE)
  unset(HAVE_CRYPT_R CACHE)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Crypt::Crypt)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_include_file(unistd.h HAVE_UNISTD_H)
    check_include_file(crypt.h HAVE_CRYPT_H)

    if(HAVE_UNISTD_H)
      list(APPEND headers "unistd.h")
    endif()
    if(HAVE_CRYPT_H)
      list(APPEND headers "crypt.h")
    endif()

    check_symbol_exists(crypt "${headers}" HAVE_CRYPT)
    check_symbol_exists(crypt_r "${headers}" HAVE_CRYPT_R)
  cmake_pop_check_state()

  if(NOT HAVE_CRYPT)
    message(
      FATAL_ERROR
      "Cannot use external crypt library as crypt() is missing."
    )
  endif()

  if(NOT HAVE_CRYPT_R)
    message(
      FATAL_ERROR
      "Cannot use external crypt library as crypt_r() is missing."
    )
  endif()
endfunction()

# Detect the style of crypt_r() if any is available.
function(_php_check_crypt_r result)
  set(${result} TRUE PARENT_SCOPE)

  unset(CRYPT_R_CRYPTD CACHE)
  unset(CRYPT_R_STRUCT_CRYPT_DATA CACHE)
  unset(CRYPT_R_GNU_SOURCE CACHE)
  unset(_CRYPT_R_STRUCT_CRYPT_DATA CACHE)

  message(CHECK_START "Checking crypt_r() data struct")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Crypt::Crypt)

    check_source_compiles(C [[
      #define _REENTRANT 1
      #include <crypt.h>

      int main(void)
      {
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

    check_source_compiles(C [[
      #define _REENTRANT 1
      #include <crypt.h>

      int main(void)
      {
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

    cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
      check_source_compiles(C [[
        #define _REENTRANT 1
        #include <crypt.h>

        int main(void)
        {
          struct crypt_data buffer;
          crypt_r("passwd", "hash", &buffer);

          return 0;
        }
      ]] CRYPT_R_GNU_SOURCE)
    cmake_pop_check_state()

    if(CRYPT_R_GNU_SOURCE)
      set(
        CRYPT_R_STRUCT_CRYPT_DATA TRUE
        CACHE INTERNAL "Define if crypt_r uses struct crypt_data"
      )

      message(CHECK_PASS "GNU struct crypt_data")
      cmake_pop_check_state()
      return()
    endif()

    check_source_compiles(C [[
      #include <stdlib.h>
      #include <unistd.h>

      int main(void)
      {
        struct crypt_data buffer;
        crypt_r("passwd", "hash", &buffer);

        return 0;
      }
    ]] _CRYPT_R_STRUCT_CRYPT_DATA)

    if(_CRYPT_R_STRUCT_CRYPT_DATA)
      set(
        CRYPT_R_STRUCT_CRYPT_DATA TRUE
        CACHE INTERNAL "Define if crypt_r uses struct crypt_data"
      )

      message(CHECK_PASS "struct crypt_data")
      cmake_pop_check_state()
      return()
    endif()

  cmake_pop_check_state()

  message(CHECK_FAIL "none")

  set(${result} FALSE PARENT_SCOPE)
endfunction()

# Check if crypt library is usable.
function(_php_check_crypt_is_usable)
  unset(_crypt_des CACHE)
  unset(_crypt_ext_des CACHE)
  unset(_crypt_md5 CACHE)
  unset(_crypt_blowfish CACHE)
  unset(_crypt_sha512 CACHE)
  unset(_crypt_sha256 CACHE)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    if(HAVE_UNISTD_H)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H)
    endif()

    if(HAVE_CRYPT_H)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_CRYPT_H)
    endif()

    set(CMAKE_REQUIRED_LIBRARIES Crypt::Crypt)

    message(CHECK_START "Checking for standard DES algo")
    if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
      message(CHECK_PASS "yes (cross-compiling)")
      set(_PHP_CRYPT_DES_EXITCODE 0)
    endif()
    check_source_runs(C [[
      #include <string.h>

      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #ifdef HAVE_CRYPT_H
      # include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void)
      {
        char *encrypted = crypt("rasmuslerdorf", "rl");
        return !encrypted || strcmp(encrypted, "rl.3StKT.4T8M");
      }
    ]] _PHP_CRYPT_HAVE_DES)
    if(_PHP_CRYPT_HAVE_DES)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Cannot use external crypt library as DES algo is missing."
      )
    endif()

    message(CHECK_START "Checking for extended DES algo")
    check_source_runs(C [[
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #ifdef HAVE_CRYPT_H
      # include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void)
      {
        char *encrypted = crypt("rasmuslerdorf", "_J9..rasm");
        return !encrypted || strcmp(encrypted, "_J9..rasmBYk8r9AiWNc");
      }
    ]] _PHP_CRYPT_HAVE_EXT_DES)
    if(_PHP_CRYPT_HAVE_EXT_DES)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Cannot use external crypt library as extended DES algo is missing."
      )
    endif()

    message(CHECK_START "Checking for MD5 algo")
    check_source_runs(C [[
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #ifdef HAVE_CRYPT_H
      # include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void)
      {
        char salt[15], answer[40];
        char *encrypted;

        salt[0]='$'; salt[1]='1'; salt[2]='$';
        salt[3]='r'; salt[4]='a'; salt[5]='s';
        salt[6]='m'; salt[7]='u'; salt[8]='s';
        salt[9]='l'; salt[10]='e'; salt[11]='$';
        salt[12]='\0';
        strcpy(answer, salt);
        strcat(answer, "rISCgZzpwk3UhDidwXvin0");
        encrypted = crypt("rasmuslerdorf", salt);
        return !encrypted || strcmp(encrypted, answer);
      }
    ]] _PHP_CRYPT_HAVE_MD5)
    if(_PHP_CRYPT_HAVE_MD5)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Cannot use external crypt library as MD5 algo is missing."
      )
    endif()

    message(CHECK_START "Checking for Blowfish algo")
    check_source_runs(C [[
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #ifdef HAVE_CRYPT_H
      # include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void)
      {
        char salt[30], answer[70];
        char *encrypted;

        salt[0]='$'; salt[1]='2'; salt[2]='a'; salt[3]='$';
        salt[4]='0'; salt[5]='7'; salt[6]='$'; salt[7]='\0';
        strcat(salt, "rasmuslerd............");
        strcpy(answer, salt);
        strcpy(&answer[29], "nIdrcHdxcUxWomQX9j6kvERCFjTg7Ra");
        encrypted = crypt("rasmuslerdorf", salt);
        return !encrypted || strcmp(encrypted, answer);
      }
    ]] _PHP_CRYPT_HAVE_BLOWFISH)
    if(_PHP_CRYPT_HAVE_BLOWFISH)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Cannot use external crypt library as Blowfish algo is missing."
      )
    endif()

    message(CHECK_START "Checking for SHA-256 algo")
    check_source_runs(C [[
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #ifdef HAVE_CRYPT_H
      # include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void)
      {
        char salt[21], answer[21+43];
        char *encrypted;

        strcpy(salt, "$5$rasmuslerdorf$");
        strcpy(answer, salt);
        strcat(answer, "cFAm2puLCujQ9t.0CxiFIIvFi4JyQx5UncCt/xRIX23");
        encrypted = crypt("rasmuslerdorf", salt);
        return !encrypted || strcmp(encrypted, answer);
      }
    ]] _PHP_CRYPT_HAVE_SHA256)
    if(_PHP_CRYPT_HAVE_SHA256)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Cannot use external crypt library as SHA-256 algo is missing."
      )
    endif()

    message(CHECK_START "Checking for SHA512 algo")
    check_source_runs(C [[
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #ifdef HAVE_CRYPT_H
      # include <crypt.h>
      #endif

      #include <stdlib.h>
      #include <string.h>

      int main(void)
      {
        char salt[21], answer[21+86];
        char *encrypted;

        strcpy(salt, "$6$rasmuslerdorf$");
        strcpy(answer, salt);
        strcat(answer, "EeHCRjm0bljalWuALHSTs1NB9ipEiLEXLhYeXdOpx22gmlmVejnVXFhd84cEKbYxCo.XuUTrW.RLraeEnsvWs/");
        encrypted = crypt("rasmuslerdorf", salt);
        return !encrypted || strcmp(encrypted, answer);
      }
    ]] _PHP_CRYPT_HAVE_SHA512)

    if(_PHP_CRYPT_HAVE_SHA512)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Cannot use external crypt library as SHA512 algo is missing."
      )
    endif()
  cmake_pop_check_state()
endfunction()

block()
  _php_check_crypt()

  _php_check_crypt_r(result)
  if(NOT result)
    message(
      FATAL_ERROR
      "Cannot use external crypt library as 'crypt_r()' style could not be "
      "detected."
    )
  endif()

  _php_check_crypt_is_usable()
endblock()
