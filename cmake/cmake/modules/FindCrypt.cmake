#[=============================================================================[
Find the crypt library and run a set of PHP specific checks if library works.

The Crypt library can be on some systems part of the standard C library. The
crypt() and crypt_r() functions are usually declared in the unistd.h or crypt.h.
The GNU C library removed the crypt library in version 2.39 and replaced it with
the libxcrypt, at the time of writing, located at
https://github.com/besser82/libxcrypt.

Module defines the following IMPORTED target(s):

  Crypt::Crypt
    The package library, if found.

Result variables:

  Crypt_FOUND
    Whether the package has been found.
  Crypt_INCLUDE_DIRS
    Include directories needed to use this package.
  Crypt_LIBRARIES
    Libraries needed to link to the package library.
  Crypt_VERSION
    Package version, if found.

Cache variables:

  Crypt_IS_BUILT_IN
    Whether crypt is a part of the C library.
  Crypt_INCLUDE_DIR
    Directory containing package library headers.
  Crypt_LIBRARY
    The path to the package library.
  HAVE_CRYPT_H
  HAVE_CRYPT
  HAVE_CRYPT_R
  CRYPT_R_CRYPTD
  CRYPT_R_STRUCT_CRYPT_DATA
  CRYPT_R_GNU_SOURCE

Hints:
  The Crypt_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Crypt
  PROPERTIES
    DESCRIPTION "Crypt library"
)

################################################################################
# Module helpers.
################################################################################

# Check whether crypt() and crypt_r() are available.
function(_crypt_check_crypt result)
  message(CHECK_START "Checking basic crypt functionality")

  unset(HAVE_CRYPT_H CACHE)
  unset(HAVE_CRYPT CACHE)
  unset(HAVE_CRYPT_R CACHE)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${Crypt_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${Crypt_LIBRARY})
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

  if(HAVE_CRYPT AND HAVE_CRYPT_R)
    set(${result} TRUE PARENT_SCOPE)
    message(CHECK_PASS "Success")
  else()
    set(${result} FALSE PARENT_SCOPE)
    message(CHECK_FAIL "Failed")
  endif()
endfunction()

# Detect the style of crypt_r() if any is available.
function(_crypt_check_crypt_r result)
  set(${result} TRUE PARENT_SCOPE)

  unset(CRYPT_R_CRYPTD CACHE)
  unset(CRYPT_R_STRUCT_CRYPT_DATA CACHE)
  unset(CRYPT_R_GNU_SOURCE CACHE)
  unset(_CRYPT_R_STRUCT_CRYPT_DATA CACHE)

  message(CHECK_START "Checking crypt_r() data struct")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${Crypt_LIBRARY})
    set(CMAKE_REQUIRED_INCLUDES ${Crypt_INCLUDE_DIR})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
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

    check_source_compiles(C [[
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

    cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
      check_source_compiles(C [[
        #define _REENTRANT 1
        #include <crypt.h>

        int main(void) {
          struct crypt_data buffer;
          crypt_r("passwd", "hash", &buffer);

          return 0;
        }
      ]] CRYPT_R_GNU_SOURCE)
    cmake_pop_check_state()

    if(CRYPT_R_GNU_SOURCE)
      set(
        CRYPT_R_STRUCT_CRYPT_DATA 1
        CACHE INTERNAL "Define if crypt_r uses struct crypt_data"
      )

      message(CHECK_PASS "GNU struct crypt_data")
      cmake_pop_check_state()
      return()
    endif()

    check_source_compiles(C [[
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

  set(${result} FALSE PARENT_SCOPE)
endfunction()

# Check if crypt library is usable.
function(_crypt_check_crypt_is_usable result)
  unset(_crypt_des CACHE)
  unset(_crypt_ext_des CACHE)
  unset(_crypt_md5 CACHE)
  unset(_crypt_blowfish CACHE)
  unset(_crypt_sha512 CACHE)
  unset(_crypt_sha256 CACHE)

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

    set(CMAKE_REQUIRED_LIBRARIES ${Crypt_LIBRARY})
    set(CMAKE_REQUIRED_INCLUDES ${Crypt_INCLUDE_DIR})
    set(CMAKE_REQUIRED_QUIET TRUE)

    message(CHECK_START "Checking for standard DES crypt")

    if(CMAKE_CROSSCOMPILING)
      message(CHECK_PASS "yes (cross-compiling)")
      set(_crypt_des ON)
    else()
      check_source_runs(C [[
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
          char *encrypted = crypt("rasmuslerdorf", "rl");
          return !encrypted || strcmp(encrypted, "rl.3StKT.4T8M");
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
      check_source_runs(C [[
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
          char *encrypted = crypt("rasmuslerdorf", "_J9..rasm");
          return !encrypted || strcmp(encrypted, "_J9..rasmBYk8r9AiWNc");
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
      check_source_runs(C [[
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
          salt[12]='\0';
          strcpy(answer, salt);
          strcat(answer, "rISCgZzpwk3UhDidwXvin0");
          encrypted = crypt("rasmuslerdorf", salt);
          return !encrypted || strcmp(encrypted, answer);
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
      check_source_runs(C [[
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
          salt[4]='0'; salt[5]='7'; salt[6]='$'; salt[7]='\0';
          strcat(salt, "rasmuslerd............");
          strcpy(answer, salt);
          strcpy(&answer[29], "nIdrcHdxcUxWomQX9j6kvERCFjTg7Ra");
          encrypted = crypt("rasmuslerdorf", salt);
          return !encrypted || strcmp(encrypted, answer);
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
      check_source_runs(C [[
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

          strcpy(salt, "$6$rasmuslerdorf$");
          strcpy(answer, salt);
          strcat(answer, "EeHCRjm0bljalWuALHSTs1NB9ipEiLEXLhYeXdOpx22gmlmVejnVXFhd84cEKbYxCo.XuUTrW.RLraeEnsvWs/");
          encrypted = crypt("rasmuslerdorf", salt);
          return !encrypted || strcmp(encrypted, answer);
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
      check_source_runs(C [[
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

          strcpy(salt, "$5$rasmuslerdorf$");
          strcpy(answer, salt);
          strcat(answer, "cFAm2puLCujQ9t.0CxiFIIvFi4JyQx5UncCt/xRIX23");
          encrypted = crypt("rasmuslerdorf", salt);
          return !encrypted || strcmp(encrypted, answer);
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
    set(${result} FALSE PARENT_SCOPE)
  else()
    set(${result} TRUE PARENT_SCOPE)
  endif()
endfunction()

################################################################################
# Find package.
################################################################################

set(_reason "")

# If no compiler is loaded, Crypt in C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(Crypt_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED Crypt_IS_BUILT_IN)
  block(PROPAGATE Crypt_IS_BUILT_IN _crypt_works)
    _crypt_check_crypt(_crypt_works)
    if(_crypt_works)
      _crypt_check_crypt_r(_crypt_r_works)
    endif()

    if(_crypt_r_works)
      _crypt_check_crypt_is_usable(_crypt_is_usable)
    endif()

    if(_crypt_works AND _crypt_r_works AND _crypt_is_usable)
      set(
        Crypt_IS_BUILT_IN TRUE
        CACHE INTERNAL "Whether crypt is a part of the C library"
      )
    else()
      set(Crypt_IS_BUILT_IN FALSE)
    endif()
  endblock()
endif()

set(_Crypt_REQUIRED_VARS)
if(Crypt_IS_BUILT_IN)
  set(_Crypt_REQUIRED_VARS _Crypt_IS_BUILT_IN_MSG)
  set(_Crypt_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_Crypt_REQUIRED_VARS Crypt_LIBRARY Crypt_INCLUDE_DIR)

  # Use pkgconf, if available on the system.
  find_package(PkgConfig QUIET)
  pkg_search_module(PC_Crypt QUIET libcrypt libxcrypt)

  find_path(
    Crypt_INCLUDE_DIR
    NAMES crypt.h unistd.h
    PATHS ${PC_Crypt_INCLUDE_DIRS}
    DOC "Directory containing Crypt library headers"
  )

  if(NOT Crypt_INCLUDE_DIR)
    string(APPEND _reason "crypt.h not found. ")
  endif()

  find_library(
    Crypt_LIBRARY
    NAMES crypt
    PATHS ${PC_Crypt_LIBRARY_DIRS}
    DOC "The path to the crypt library"
  )

  if(NOT Crypt_LIBRARY)
    string(APPEND _reason "crypt library not found. ")
  endif()

  block()
    _crypt_check_crypt(_crypt_works)
    list(APPEND _Crypt_REQUIRED_VARS _crypt_works)
    if(NOT _crypt_works)
      string(APPEND _reason "crypt library doesn't work")
    endif()
  endblock()

  _crypt_check_crypt_r(_crypt_r_works)

  _crypt_check_crypt_is_usable(_crypt_is_usable)

  mark_as_advanced(Crypt_INCLUDE_DIR Crypt_LIBRARY)
endif()

if(NOT HAVE_CRYPT_R)
  string(APPEND _reason "Required crypt_r could not be found. ")
endif()

if(NOT _crypt_r_works)
  string(APPEND _reason "Unable to detect data struct used by crypt_r. ")
endif()

# Get version.
block(PROPAGATE Crypt_VERSION)
  if(Crypt_INCLUDE_DIR AND EXISTS ${Crypt_INCLUDE_DIR}/crypt.h)
    set(regex [[^[ \t]*#[ \t]*define[ \t]+XCRYPT_VERSION_STR[ \t]+"?([0-9.]+)"?[ \t]*$]])

    file(STRINGS ${Crypt_INCLUDE_DIR}/crypt.h results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(Crypt_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()

  if(NOT Crypt_VERSION AND PC_Crypt_VERSION)
    cmake_path(
      COMPARE
      "${PC_Crypt_INCLUDEDIR}" EQUAL "${Crypt_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(Crypt_VERSION ${PC_Crypt_VERSION})
    endif()
  endif()
endblock()

list(APPEND _Crypt_REQUIRED_VARS _crypt_is_usable)
if(NOT _crypt_is_usable)
  string(APPEND _reason "Crypt algorithms not found in the crypt library. ")
endif()

################################################################################
# Handle find_package arguments.
################################################################################

find_package_handle_standard_args(
  Crypt
  REQUIRED_VARS
    ${_Crypt_REQUIRED_VARS}
    HAVE_CRYPT_R
    _crypt_r_works
  VERSION_VAR Crypt_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_Crypt_REQUIRED_VARS)
unset(_Crypt_IS_BUILT_IN_MSG)
unset(_crypt_r_works)

if(NOT Crypt_FOUND)
  return()
endif()

if(Crypt_IS_BUILT_IN)
  set(Crypt_INCLUDE_DIRS "")
  set(Crypt_LIBRARIES "")
else()
  set(Crypt_INCLUDE_DIRS ${Crypt_INCLUDE_DIR})
  set(Crypt_LIBRARIES ${Crypt_LIBRARY})
endif()

if(NOT TARGET Crypt::Crypt)
  add_library(Crypt::Crypt UNKNOWN IMPORTED)

  if(Crypt_INCLUDE_DIR)
    set_target_properties(
      Crypt::Crypt
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Crypt_INCLUDE_DIR}"
    )
  endif()

  if(Crypt_LIBRARY)
    set_target_properties(
      Crypt::Crypt
      PROPERTIES
        IMPORTED_LOCATION "${Crypt_LIBRARY}"
    )
  endif()
endif()
