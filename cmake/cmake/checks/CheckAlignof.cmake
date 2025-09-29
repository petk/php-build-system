#[=============================================================================[
This check determines whether the compiler supports __alignof__.

Result variables:

* HAVE_ALIGNOF
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_ALIGNOF FALSE)
  return()
endif()

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_HAVE_ALIGNOF)
  message(CHECK_START "Checking whether the compiler supports __alignof__")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
      int main(void)
      {
        int align = __alignof__(int);
        (void)align;
        return 0;
      }
    ]] PHP_HAVE_ALIGNOF)
  cmake_pop_check_state()
  if(PHP_HAVE_ALIGNOF)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_ALIGNOF ${PHP_HAVE_ALIGNOF})
