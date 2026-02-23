#[=============================================================================[
Check for reentrant functions and their declarations.

Some systems didn't declare some reentrant functions if '_REENTRANT' or
'_POSIX_C_SOURCE' was not defined (certain versions of mingw etc.). This is
mostly obsolete. The CMake's 'check_symbol_exists()' is sufficient to check for
reentrant functions on current systems and this check might be obsolete in the
future.

Result variables:

* HAVE_ASCTIME_R - Whether asctime_r() is available.
* HAVE_CTIME_R - Whether ctime_r() is available.
* HAVE_GMTIME_R - Whether gmtime_r() is available.
* HAVE_LOCALTIME_R - Whether localtime_r() is available.
* HAVE_STRTOK_R - Whether strtok_r() is available.
* MISSING_ASCTIME_R_DECL - Whether asctime_r() is not declared.
* MISSING_CTIME_R_DECL - Whether ctime_r() is not declared.
* MISSING_GMTIME_R_DECL - Whether gmtime_r() is not declared.
* MISSING_LOCALTIME_R_DECL - Whether localtime_r() is not declared.
* MISSING_STRTOK_R_DECL - Whether strtok_r() is not declared.

Also the type of reentrant time-related functions are checked. Type can be IRIX,
or POSIX style. This check is obsolete as it is relevant only for obsolete
systems.

Cache variables:

* PHP_IRIX_TIME_R - Whether IRIX-style functions are used (e.g., Solaris <= 11.3
  and illumos without _POSIX_PTHREAD_SEMANTICS defined).
#]=============================================================================]

include(CheckFunctionExists)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

# Define HAVE_<symbol> if linker sees the function, and MISSING_<symbol>_DECL if
# function is not declared by checking the required header and test body.
function(_php_check_reentrant_function symbol header)
  string(TOUPPER "${symbol}" const)

  set(HAVE_${const} FALSE)
  set(MISSING_${const}_DECL TRUE)

  # Reentrant functions checked in this module aren't available on Windows.
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    return(PROPAGATE HAVE_${const} MISSING_${const}_DECL)
  endif()

  check_symbol_exists(${symbol} "${header}" PHP_HAS_${const})

  if(PHP_HAS_${const})
    set(HAVE_${const} TRUE)
    set(MISSING_${const}_DECL FALSE)

    return(PROPAGATE HAVE_${const} MISSING_${const}_DECL)
  endif()

  check_function_exists(${symbol} PHP_HAS_FUNCTION_${const})

  if(PHP_HAS_FUNCTION_${const})
    set(HAVE_${const} TRUE)

    return(PROPAGATE HAVE_${const} MISSING_${const}_DECL)
  endif()

  return(PROPAGATE HAVE_${const} MISSING_${const}_DECL)
endfunction()

_php_check_reentrant_function(asctime_r time.h)
_php_check_reentrant_function(ctime_r time.h)
_php_check_reentrant_function(gmtime_r time.h)
_php_check_reentrant_function(localtime_r time.h)
_php_check_reentrant_function(strtok_r string.h)

################################################################################
# Check type of reentrant time-related functions.
################################################################################

if(NOT HAVE_ASCTIME_R OR NOT HAVE_GMTIME_R)
  return()
endif()

# Skip in consecutive configuration phases.
if(DEFINED PHP_IRIX_TIME_R)
  return()
endif()

# When cross-compiling, assume POSIX style.
if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_IRIX_TIME_R_EXITCODE 1)
endif()

message(CHECK_START "Checking type of reentrant time-related functions")

cmake_push_check_state(RESET)
  # To get the POSIX standard conforming *_r functions declarations:
  # - _POSIX_PTHREAD_SEMANTICS is needed on Solaris <= 11.3 and illumos
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

  check_source_runs(C [[
    #include <time.h>

    int main(void)
    {
      struct tm t, *s;
      time_t old = 0;
      char buf[27], *p;

      s = gmtime_r(&old, &t);
      p = asctime_r(&t, buf, 26);
      if (p == buf && s == &t) {
        return 0;
      }

      return 1;
    }
  ]] PHP_IRIX_TIME_R)
cmake_pop_check_state()

if(PHP_IRIX_TIME_R)
  message(CHECK_PASS "IRIX")
else()
  message(CHECK_PASS "POSIX")
endif()
