#[=============================================================================[
Check if any of the expected headers define TIOCGWINSZ. Some systems define
TIOCGWINSZ (Terminal Input Output Control Get WINdow SiZe) to obtain the number
of rows and columns in the terminal window. This is based on Autoconf's
AC_HEADER_TIOCGWINSZ macro approach.

Result variables:

* GWINSZ_IN_SYS_IOCTL - Whether <sys/ioctl.h> defines TIOCGWINSZ.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSymbolExists)
include(CMakePushCheckState)

set(GWINSZ_IN_SYS_IOCTL FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

# Skip in consecutive configuration phases.
if(DEFINED PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_TERMINOS)
  if(PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_SYS_IOCTL)
    set(GWINSZ_IN_SYS_IOCTL TRUE)
  endif()
  return()
endif()

message(CHECK_START "Checking whether termios.h defines TIOCGWINSZ")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(
    TIOCGWINSZ
    termios.h
    PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_TERMINOS
  )
cmake_pop_check_state()

if(PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_TERMINOS)
  message(CHECK_PASS "yes")
  return()
endif()

message(CHECK_FAIL "no")

message(CHECK_START "Checking whether sys/ioctl.h defines TIOCGWINSZ")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(
    TIOCGWINSZ
    sys/ioctl.h
    PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_SYS_IOCTL
  )
cmake_pop_check_state()

if(PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_SYS_IOCTL)
  set(GWINSZ_IN_SYS_IOCTL TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
