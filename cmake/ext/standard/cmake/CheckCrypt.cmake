#[=============================================================================[
Check whether the 'crypt' library works as expected for PHP by running a set of
PHP-specific checks.

Result variables:

* HAVE_CRYPT_H
* HAVE_CRYPT
* HAVE_CRYPT_R
* CRYPT_R_CRYPTD
* CRYPT_R_STRUCT_CRYPT_DATA
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

# Check whether crypt() and crypt_r() are available.
function(_php_ext_standard_check_crypt)
  # Skip in consecutive configuration phases.
  if(PHP_HAVE_CRYPT_H AND PHP_HAVE_CRYPT AND PHP_HAVE_CRYPT_R)
    set(HAVE_CRYPT_H ${PHP_HAVE_CRYPT_H})
    set(HAVE_CRYPT ${PHP_HAVE_CRYPT})
    set(HAVE_CRYPT_R ${PHP_HAVE_CRYPT_R})

    return(PROPAGATE HAVE_CRYPT_H HAVE_CRYPT HAVE_CRYPT_R)
  endif()

  message(CHECK_START "Checking basic crypt functionality")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Crypt::Crypt)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_include_files(unistd.h PHP_HAVE_UNISTD_H)

    check_include_files(crypt.h PHP_HAVE_CRYPT_H)
    set(HAVE_CRYPT_H ${PHP_HAVE_CRYPT_H})

    if(PHP_HAVE_UNISTD_H)
      list(APPEND headers "unistd.h")
    endif()
    if(PHP_HAVE_CRYPT_H)
      list(APPEND headers "crypt.h")
    endif()

    check_symbol_exists(crypt "${headers}" PHP_HAVE_CRYPT)
    set(HAVE_CRYPT ${PHP_HAVE_CRYPT})

    check_symbol_exists(crypt_r "${headers}" PHP_HAVE_CRYPT_R)
    set(HAVE_CRYPT_R ${PHP_HAVE_CRYPT_R})
  cmake_pop_check_state()

  if(NOT PHP_HAVE_CRYPT)
    message(
      FATAL_ERROR
      "Cannot use external crypt library as crypt() is missing."
    )
  endif()

  if(NOT PHP_HAVE_CRYPT_R)
    message(
      FATAL_ERROR
      "Cannot use external crypt library as crypt_r() is missing."
    )
  endif()

  return(PROPAGATE HAVE_CRYPT_H HAVE_CRYPT HAVE_CRYPT_R)
endfunction()

# Detect the style of crypt_r() if any is available.
function(_php_ext_standard_check_crypt_r)
  # Skip in consecutive configuration phases.
  if(DEFINED PHP_CRYPT_R_CRYPTD)
    set(CRYPT_R_CRYPTD ${PHP_CRYPT_R_CRYPTD} PARENT_SCOPE)

    if(DEFINED PHP_CRYPT_R_STRUCT_CRYPT_DATA)
      set(
        CRYPT_R_STRUCT_CRYPT_DATA
        ${PHP_CRYPT_R_STRUCT_CRYPT_DATA}
        PARENT_SCOPE
      )
    endif()

    return()
  endif()

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
    ]] PHP_CRYPT_R_CRYPTD)
    set(CRYPT_R_CRYPTD ${PHP_CRYPT_R_CRYPTD} PARENT_SCOPE)

    if(PHP_CRYPT_R_CRYPTD)
      message(CHECK_PASS "cryptd")
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
      ]] PHP_CRYPT_R_STRUCT_CRYPT_DATA)
    cmake_pop_check_state()

    if(NOT PHP_CRYPT_R_STRUCT_CRYPT_DATA)
      unset(CACHE{PHP_CRYPT_R_STRUCT_CRYPT_DATA})

      check_source_compiles(C [[
        #include <stdlib.h>
        #include <unistd.h>

        int main(void)
        {
          struct crypt_data buffer;
          crypt_r("passwd", "hash", &buffer);

          return 0;
        }
      ]] PHP_CRYPT_R_STRUCT_CRYPT_DATA)
    endif()
  cmake_pop_check_state()

  set(CRYPT_R_STRUCT_CRYPT_DATA ${PHP_CRYPT_R_STRUCT_CRYPT_DATA} PARENT_SCOPE)

  if(PHP_CRYPT_R_STRUCT_CRYPT_DATA)
    message(CHECK_PASS "struct crypt_data")
    return()
  endif()

  message(CHECK_FAIL "none")

  message(
    FATAL_ERROR
    "Cannot use external crypt library as 'crypt_r()' style could not be "
    "detected."
  )
endfunction()

# Check if crypt library is usable.
function(_php_ext_standard_check_crypt_is_usable)
  # Skip in consecutive configuration phases.
  if(
    PHP_HAVE_CRYPT_BLOWFISH
    AND PHP_HAVE_CRYPT_EXT_DES
    AND PHP_HAVE_CRYPT_MD5
    AND PHP_HAVE_CRYPT_SHA256
    AND PHP_HAVE_CRYPT_SHA512
  )
    return()
  endif()

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    if(PHP_HAVE_UNISTD_H)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H)
    endif()

    if(PHP_HAVE_CRYPT_H)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_CRYPT_H)
    endif()

    set(CMAKE_REQUIRED_LIBRARIES Crypt::Crypt)

    message(CHECK_START "Checking for standard DES algo")
    if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
      message(CHECK_PASS "yes (cross-compiling)")
      set(PHP_HAVE_CRYPT_DES_EXITCODE 0)
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
    ]] PHP_HAVE_CRYPT_DES)
    if(PHP_HAVE_CRYPT_DES)
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
    ]] PHP_HAVE_CRYPT_EXT_DES)
    if(PHP_HAVE_CRYPT_EXT_DES)
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
    ]] PHP_HAVE_CRYPT_MD5)
    if(PHP_HAVE_CRYPT_MD5)
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
    ]] PHP_HAVE_CRYPT_BLOWFISH)
    if(PHP_HAVE_CRYPT_BLOWFISH)
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
    ]] PHP_HAVE_CRYPT_SHA256)
    if(PHP_HAVE_CRYPT_SHA256)
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
    ]] PHP_HAVE_CRYPT_SHA512)

    if(PHP_HAVE_CRYPT_SHA512)
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

_php_ext_standard_check_crypt()
_php_ext_standard_check_crypt_r()
_php_ext_standard_check_crypt_is_usable()
