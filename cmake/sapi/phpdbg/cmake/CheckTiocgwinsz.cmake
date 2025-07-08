#[=============================================================================[
This check is based on the approach used by Autoconf's AC_HEADER_TIOCGWINSZ
macro to determine whether any of the expected headers define the TIOCGWINSZ
(Terminal Input/Output Control Get WINdow SiZe) preprocessor macro. Although
TIOCGWINSZ is not part of the POSIX specification, it is commonly defined on
POSIX-like systems to obtain the number of rows and columns in a terminal
window.

- If <termios.h> defines TIOCGWINSZ, the GWINSZ_IN_SYS_IOCTL result variable is
  set to boolean false. For example, on macOS, BSD, Solaris/illumos, Haiku.
- Otherwise, additional check is performed whether <sys/ioctl.h> defines
  TIOCGWINSZ. If it does, the GWINSZ_IN_SYS_IOCTL result variable is set to
  boolean true. For example, on Linux.
- On Windows, TIOCGWINSZ is not available.
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)

function(_php_sapi_phpdbg_check_tiocgwinsz result)
  set(${result} FALSE)

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    return(PROPAGATE ${result})
  endif()

  if(PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_IN_SYS_IOCTL)
    set(${result} TRUE)
    return(PROPAGATE ${result})
  endif()

  if(DEFINED PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_IN_TERMIOS)
    return(PROPAGATE ${result})
  endif()

  message(CHECK_START "Checking whether <termios.h> defines TIOCGWINSZ")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(
      TIOCGWINSZ
      termios.h
      PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_IN_TERMIOS
    )
  cmake_pop_check_state()
  if(PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_IN_TERMIOS)
    message(CHECK_PASS "yes")
    return(PROPAGATE ${result})
  endif()
  message(CHECK_FAIL "no")

  message(CHECK_START "Checking whether <sys/ioctl.h> defines TIOCGWINSZ")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(
      TIOCGWINSZ
      sys/ioctl.h
      PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_IN_SYS_IOCTL
    )
  cmake_pop_check_state()
  if(PHP_SAPI_PHPDBG_HAS_TIOCGWINSZ_IN_SYS_IOCTL)
    message(CHECK_PASS "yes")
    set(${result} TRUE)
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

_php_sapi_phpdbg_check_tiocgwinsz(GWINSZ_IN_SYS_IOCTL)
