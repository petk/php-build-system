#[=============================================================================[
# CheckTiocgwinsz

Check if any of the expected headers define `TIOCGWINSZ`.

Some systems define `TIOCGWINSZ` (Terminal Input Output Control Get WINdow SiZe)
to obtain the number of rows and columns in the terminal window. This is based
on Autoconf's `AC_HEADER_TIOCGWINSZ` macro approach.

## Cache variables

* `GWINSZ_IN_SYS_IOCTL`

  Whether `sys/ioctl.h` defines `TIOCGWINSZ`.

## Usage

```cmake
# CMakeLists.txt
include(cmake/CheckTiocgwinsz.cmake)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking whether termios.h defines TIOCGWINSZ")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(TIOCGWINSZ termios.h PHP_HAS_TIOCGWINSZ_IN_TERMIOS_H)
cmake_pop_check_state()

if(NOT PHP_HAS_TIOCGWINSZ_IN_TERMIOS_H)
  message(CHECK_FAIL "no")

  message(CHECK_START "Checking whether sys/ioctl.h defines TIOCGWINSZ")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(TIOCGWINSZ sys/ioctl.h GWINSZ_IN_SYS_IOCTL)
  cmake_pop_check_state()

  if(GWINSZ_IN_SYS_IOCTL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
else()
  message(CHECK_PASS "yes")
endif()
