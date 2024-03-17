#[=============================================================================[
Check for reentrant functions and their declarations.

Some systems didn't declare some reentrant functions if _REENTRANT was not
defined. This is mostly obsolete and is intended for the PHP code specific
usage. The check_symbol_exists() is sufficient to check for reentrant functions
on current systems and this module might be obsolete in the future.

Cache variables:

  HAVE_LOCALTIME_R
    Whether localtime_r() is available.
  MISSING_LOCALTIME_R_DECL
    Whether localtime_r is not declared.
  HAVE_GMTIME_R
    Whether gmtime_r() is available.
  MISSING_GMTIME_R_DECL
    Whether gmtime_r is not declared.
  HAVE_ASCTIME_R
    Whether asctime_r() is available.
  MISSING_ASCTIME_R_DECL
    Whether asctime_r is not declared.
  HAVE_CTIME_R
    Whether ctime_r() is available.
  MISSING_CTIME_R_DECL
    Whether ctime_r is not declared.
  HAVE_STRTOK_R
    Whether strtok_r() is available.
  MISSING_STRTOK_R_DECL
    Whether strtok_r is not declared.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckFunctionExists)
include(CheckSourceCompiles)
include(CMakePushCheckState)

# Define HAVE_<symbol> if linker sees the function, and MISSING_<symbol>_DECL if
# function is not declared by checking the required header and given test body.
function(_php_check_reentrant_function symbol header body)
  string(TOUPPER "${symbol}" const)

  # Check if linker sees the function.
  check_function_exists(${symbol} HAVE_${const})

  message(CHECK_START "Checking ${symbol} declaration")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C "
      #include <${header}>
      int main(void) {
        ${body};
        return 0;
      }
    " _have_${symbol}_declaration)
  cmake_pop_check_state()

  if(NOT _have_${symbol}_declaration)
    message(CHECK_FAIL "missing")

    set(
      MISSING_${const}_DECL 1
      CACHE INTERNAL "Define if ${symbol} is not declared."
    )
  else()
    message(CHECK_PASS "found")
  endif()
endfunction()

_php_check_reentrant_function(
  localtime_r
  time.h
  "struct tm *(*func)(void) = localtime_r"
)

_php_check_reentrant_function(
  gmtime_r
  time.h
  "struct tm *(*func)(void) = gmtime_r"
)

_php_check_reentrant_function(
  asctime_r
  time.h
  "char *(*func)(void) = asctime_r"
)
_php_check_reentrant_function(
  ctime_r
  time.h
  "char *(*func)(void) = ctime_r"
)

_php_check_reentrant_function(
  strtok_r
  string.h
  "char *(*func)(void) = strtok_r"
)
