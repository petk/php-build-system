#[=============================================================================[
This check is for some BSD systems and is most likely obsolete.

Result variables:

* HAVE_PS_STRINGS
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME MATCHES "^(Linux|Windows)$")
  set(HAVE_PS_STRINGS FALSE)
  return()
endif()

message(CHECK_START "Checking for PS_STRINGS")

cmake_push_check_state(RESET)

set(CMAKE_REQUIRED_QUIET TRUE)

check_source_compiles(
  C
  [[
    #include <machine/vmparam.h> // For old BSD.
    #include <sys/exec.h>

    int main(void)
    {
      PS_STRINGS->ps_nargvstr = 1;
      PS_STRINGS->ps_argvstr = "foo";

      return 0;
    }
  ]]
  PHP_HAVE_PS_STRINGS
)

cmake_pop_check_state()

if(PHP_HAVE_PS_STRINGS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

set(HAVE_PS_STRINGS ${PHP_HAVE_PS_STRINGS})
