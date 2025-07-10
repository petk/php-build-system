#[=============================================================================[
Check whether strerror_r() implementation is POSIX-compatible or GNU-specific.

Result variables:

* HAVE_STRERROR_R
* STRERROR_R_CHAR_P
#]=============================================================================]

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)

set(HAVE_STRERROR_R FALSE)
set(STRERROR_R_CHAR_P FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

check_symbol_exists(strerror_r string.h PHP_ZEND_HAS_STRERROR_R)

if(NOT PHP_ZEND_HAS_STRERROR_R)
  return()
endif()

set(HAVE_STRERROR_R TRUE)

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_ZEND_HAS_STRERROR_R_CHAR_P)
  message(CHECK_START "Checking strerror_r() return type")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <string.h>

      int main(void)
      {
        char buf[100];
        char x = *strerror_r (0, buf, sizeof buf);
        char *p = strerror_r (0, buf, sizeof buf);
        return !p || x;
      }
    ]] PHP_ZEND_HAS_STRERROR_R_CHAR_P)
  cmake_pop_check_state()

  if(PHP_ZEND_HAS_STRERROR_R_CHAR_P)
    message(CHECK_PASS "char *")
  else()
    message(CHECK_PASS "int")
  endif()
endif()

set(STRERROR_R_CHAR_P ${PHP_ZEND_HAS_STRERROR_R_CHAR_P})
